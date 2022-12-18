import boto3
import json

# list all puzzle IDs
def lambda_handler(event=None, context=None):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('UnscramblePuzzles')

    res = table.scan(ProjectionExpression='PuzzleId')
    ids = [int(item['PuzzleId']) for item in res['Items']]
    ids.sort(reverse=True)
    
    return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "headers": {'Access-Control-Allow-Origin': '*'},
        "body": json.dumps(ids)
    }
