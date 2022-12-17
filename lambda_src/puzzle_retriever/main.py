import boto3
import json
from decimal import Decimal

# retrieves puzzle data from dynamo db by puzzle ID
def lambda_handler(event=None, context=None):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('UnscramblePuzzles')
    puzzle_id = int(event['pathParameters']['proxy'])

    res = table.get_item(Key={'PuzzleId': puzzle_id})
    puzzle_data = res['Item']['PuzzleDetail']
    puzzle_data['maxScore'] = int(puzzle_data['maxScore']) # convert decimal object to int
    
    return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "headers": {},
        "body": json.dumps(puzzle_data)
    }
