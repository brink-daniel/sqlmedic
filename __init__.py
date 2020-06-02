from flask import Flask
from flask import render_template
from dataclasses import dataclass

import glob
import os

app = Flask(__name__)

@app.route("/")
def home():
	return render_template("home.html")

@app.route("/index/")
def index():
	return render_template("index.html", scripts=get_tsql_scripts())

@app.route("/about/")
def about():
	return render_template("about.html")


@app.route("/script/<string:script_id>")
def script(script_id):
	script = get_tsql_scripts(script_id)
	if len(script) == 1:
		return render_template("script.html", scripts=script[0])
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


def get_tsql_scripts(script_id = ""):
	list = []

	for file in get_tsql_script_files():
		file_content = open(file, "r", encoding="utf-8").read().strip()
		if (script_id == "" or file_content.find("<Title>" + script_id + "</Title>") > -1):		
			list.append(
				tsql_script(
					title = get_value_from_xml_string(file_content, "<Title>"),
					description = get_value_from_xml_string(file_content, "<Description>"),
					author = get_value_from_xml_string(file_content, "<Author>"),
					date = get_value_from_xml_string(file_content, "<Date>"),
					category = get_value_from_xml_string(file_content, "<Category>"),
					script = get_license() + remove_boilerplate(file_content)
				)
			)
		if (len(script_id) > 0 and len(list) > 0):
			break

	return sorted(list, key=lambda x: (x.category, x.title))


def get_license():
	return "/*\nGNU General Public License v3.0\nhttps://github.com/brink-daniel/sqlmedic/blob/master/LICENSE\n*/\n"

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

def remove_boilerplate(value : str): 
	return value[value.find("*/") + 2:len(value)].strip()

if __name__ == "__main__":
    app.run()







