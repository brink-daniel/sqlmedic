from flask import Flask
from flask import render_template
from dataclasses import dataclass
from datetime import datetime, timedelta

import glob
import os


app = Flask(__name__)


@app.route("/")
def home():
	d = datetime.now() - timedelta(days=60)
	script = [f for f in filter(lambda x: x.date >= d, script_collection)]
	script = sorted(script, key=lambda x: (x.date, x.title), reverse=True)
	return render_template("home.html", scripts=script)


@app.route("/index/")
def index():
	return render_template("index.html", scripts=script_collection)

@app.route("/about/")
def about():
	return render_template("about.html")

@app.route("/script/<string:script_id>")
def script(script_id):
	script = next(filter(lambda x: x.title == script_id, script_collection), None)
	if script:
		return render_template("script.html", scripts=script)
	else:
		return render_template('page_not_found.html'), 404

@app.errorhandler(404)
def page_not_found(error):
    return render_template('page_not_found.html'), 404

@dataclass(order=True)
class tsql_script:
	title: str
	description: str
	author: str
	date: str
	category: str
	script: str

def get_tsql_scripts():
	list = []

	for file in get_tsql_script_files():
		file_content = open(file, "r", encoding="utf-8").read().strip()		
		list.append(
			tsql_script(
				title = get_value_from_xml_string(file_content, "<Title>"),
				description = get_value_from_xml_string(file_content, "<Description>"),
				author = get_value_from_xml_string(file_content, "<Author>"),
				date = datetime.strptime(get_value_from_xml_string(file_content, "<Date>"), '%d %b %Y'),
				category = get_value_from_xml_string(file_content, "<Category>"),
				script = get_license() + remove_boilerplate(file_content)
			)
		)		

	return sorted(list, key=lambda x: (x.category, x.title))


def get_license():
	return "/*\nGNU General Public License v3.0\nhttps://github.com/brink-daniel/sqlmedic/blob/master/LICENSE\n*/\n"

def remove_boilerplate(value : str): 
	return value[value.find("*/") + 2:len(value)].strip()

def	get_value_from_xml_string(value : str, tag : str):
	start = value.find(tag) + len(tag)
	end = value.find(tag.replace("<", "</"))
	if (start > -1 and end > -1):
		return value[start:end]
	else:
		return "#n/a"

def get_tsql_script_files():
        location = os.path.join(app.static_folder, 'tsql') + "/*.sql"
        return [f for f in glob.glob(location)]


script_collection = get_tsql_scripts()


if __name__ == "__main__":
    app.run()







