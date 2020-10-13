import time
from random import randrange

from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'

temperatures = {'Melbourne': {
    'place': 'Melbourne',
    'current_temperature': 0,
    'min_temperature': 4,
    'max_temperature': 25,
    'comments': ''
    },
    'Sydney': {
        'place': 'Sydney',
        'current_temperature': 30,
        'min_temperature': 4,
        'max_temperature': 25,
        'comments': ''
    },
    'Hobart': {
        'place': 'Hobart',
        'current_temperature': 30,
        'min_temperature': 4,
        'max_temperature': 25,
        'comments': ''
    },
    'Brisbane': {
        'place': 'Brisbane',
        'current_temperature': 30,
        'min_temperature': 4,
        'max_temperature': 25,
        'comments': ''
    },
    'Perth': {
        'place': 'Perth',
        'current_temperature': 0,
        'min_temperature': 4,
        'max_temperature': 25,
        'comments': ''
    },
    'Darwin': {
        'place': 'Darwin',
        'current_temperature': 30,
        'min_temperature': 4,
        'max_temperature': 25,
        'comments': ''
    },
    'Canberra': {
        'place': 'Canberra',
        'current_temperature': 40,
        'min_temperature': 4,
        'max_temperature': 25,
        'comments': ''
    },
    'పసలపూడి': {
        'place': 'పసలపూడి',
        'current_temperature': 35,
        'min_temperature': 4,
        'max_temperature': 25,
        'comments': ''
    }
}


@app.route('/')
def home():
    return 'Hello World!'


@app.route('/temperature/<string:place>')
def get_store(place):
    time.sleep(randrange(5))
    if place in temperatures.keys():
        return jsonify({'status': 'success', 'data': temperatures[place]}), 200

    return jsonify({'status': 'failure', 'data': 'Store not found'})


if __name__ == '__main__':
    app.run(debug=True)
