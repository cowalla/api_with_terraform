def example_handler(event, context):
    response = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            'Access-Control-Allow-Credentials': True,
        },
        "body": "HELLO WORLD",
    }

    return response
