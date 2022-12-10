import json
import requests
from bs4 import BeautifulSoup


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
    puzzle_id = '1676'
    word_data = scrape_puzzle_page(puzzle_id)

    # write to file
    # with open(f'{puzzle_id}.json', 'w') as output:
    #     json.dump(word_data, output)

    return json.dumps(word_data)
