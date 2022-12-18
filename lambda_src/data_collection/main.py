import boto3
import requests
from bs4 import BeautifulSoup


ssm = boto3.client('ssm')
dynamodb = boto3.resource('dynamodb')

def get_next_puzzle_id() -> str:
    """
    Get the next puzzle ID and increment it. This way if it fails to scrape the current day's puzzle,
    it will still move on to the next puzzle tomorrow instead of getting stuck.

    Returns:
        str: puzzle ID currently in parameter store
    """
    puzzle_id = ssm.get_parameter(Name='next_puzzle_id')['Parameter']['Value']
    ssm.put_parameter(Name='next_puzzle_id', Value=str(int(puzzle_id) + 1), Overwrite=True)

    return puzzle_id

def scrape_puzzle_page(puzzle_id: str) -> dict:
    word_data = {}
    res = requests.get(f'https://www.sbsolver.com/s/{puzzle_id}')
    soup = BeautifulSoup(res.text, 'html.parser')

    # get data from web page
    center_letter, outer_letters = scrape_letters(soup)
    word_data['centerLetter'] = center_letter
    word_data['outerLetters'] = outer_letters
    word_data['maxScore'] = scrape_max_score(soup)
    word_data['words'] = scrape_words(soup)

    return word_data

def scrape_letters(soup: BeautifulSoup) -> tuple[str, list[str]]:
    letters_element = soup.find('input', {'placeholder': '7 unique letters'})
    letters = letters_element['value'].lower()

    return (letters[0], list(letters[1:]))

def scrape_max_score(soup: BeautifulSoup) -> int:
    score_element = soup.find('a', {'title': 'click for rank listing'})
    
    return int(score_element.text.split(' ')[0])

def scrape_words(soup: BeautifulSoup) -> list[str]:
    table = soup.find('table', {'class': 'bee-set'})
    records = table.find_all('td', {'class': 'bee-hover'})

    return [word.text.lower() for word in records]

def lambda_handler(event=None, context=None):
    # can override parameter store lookup by passing puzzle ID in the event
    if 'puzzle_id' in event:
        puzzle_id = event['puzzle_id']
    else:
        puzzle_id = get_next_puzzle_id()
    
    word_data = scrape_puzzle_page(puzzle_id)

    # write to DynamoDB
    table = dynamodb.Table('UnscramblePuzzles')

    table.put_item(
        Item={
            'PuzzleId': int(puzzle_id),
            'PuzzleDetail': word_data
        }
    )
