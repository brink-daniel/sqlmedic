from flask import Flask
from flask import render_template
from dataclasses import dataclass

import glob

app = Flask(__name__)

@app.route("/")
def home():
	return render_template("home.html", scripts=get_tsql_scripts())

@app.route("/about/")
def about():
	return render_template("about.html")

@app.route("/contact/")
def contact():
	return render_template("contact.html")

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


def	get_value_from_xml_string(value : str, tag : str):
	start = value.find(tag) + len(tag)
	end = value.find(tag.replace("<", "</"))
	if (start > -1 and end > -1):
		return value[start:end]
	else:
		return "#n/a"

def get_tsql_script_files():
	return [f for f in glob.glob("static/tsql/*.sql")]

def get_tsql_scripts():
	list = []

	for file in get_tsql_script_files():
		file_content = open(file).read().strip()
		list.append(
			tsql_script(
				title = get_value_from_xml_string(file_content, "<Title>"),
				description = get_value_from_xml_string(file_content, "<Description>"),
				author = get_value_from_xml_string(file_content, "<Author>"),
				date = get_value_from_xml_string(file_content, "<Date>"),
				category = get_value_from_xml_string(file_content, "<Category>"),
				script = file_content
			)
		)

	return sorted(list, key=lambda x: (x.category, x.title))








