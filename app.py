from flask import Flask
from flask import render_template

app = Flask(__name__)

@app.route("/")
def home():
	return render_template("home.html")

@app.route("/about/")
def about():
	return render_template("about.html")

@app.route("/contact/")
def contact():
	return render_template("contact.html")

@app.errorhandler(404)
def page_not_found(error):
    return render_template('page_not_found.html'), 404
