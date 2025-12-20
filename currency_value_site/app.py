from flask import Flask, render_template
import requests
import xml.etree.ElementTree as ET
from datetime import datetime

app = Flask(__name__)

CBR_URL = "https://www.cbr.ru/scripts/XML_daily.asp"

def get_rates():
    response = requests.get(CBR_URL)
    response.encoding = 'windows-1251'
    root = ET.fromstring(response.text)

    rates = []
    for valute in root.findall('Valute'):
        rates.append({
            "char": valute.find('CharCode').text,
            "name": valute.find('Name').text,
            "value": valute.find('Value').text,
            "nominal": valute.find('Nominal').text
        })
    return rates

@app.route("/")
def index():
    rates = get_rates()
    now = datetime.now().strftime("%d.%m.%Y %H:%M:%S")
    return render_template("index.html", rates=rates, now=now)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
