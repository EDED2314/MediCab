import json
from flask import Flask, jsonify, request
import os
import scripts.mydb as db
import scripts.detect as detect
import requests
import openai
from dotenv import load_dotenv
import chatbot.chat_bot as cb

load_dotenv()

openai.api_key = os.getenv("OPENAI_API_KEY")

# __name__ == __main__
app = Flask(__name__)
fake_backend = False


@app.route("/", methods=["GET"])
def demo_test():
    return "<p>Hello Hacker [Don't hack pls :(]</p>"


@app.route("/api/detect/<string:username>", methods=["POST", "GET"])
def process_image(username):
    images = request.files.getlist("images")
    if len(images) == 0 and request.method == "POST":
        return jsonify(
            {"error": "404", "message": "Please provide images with api request!"}
        )

    if request.method == "POST":
        for image in images:
            amount_of_images = len(os.listdir("Images"))
            image.save(os.path.join("Images", f"{amount_of_images + 1}.jpg"))
        return ""

    elif request.method == "GET":
        images = os.listdir("Images")
        detections = []

        for image in images:
            class_labels = detect.get_classification(os.path.join("Images", image))
            os.remove(os.path.join("Images", image))
            for label in class_labels:
                if label not in detections:
                    if label == "peroxide":
                        continue
                    detections.append(label)

        # process image stored data
        return jsonify({"message": f"success for {username}", "detections": detections})


@app.route("/api/meds/del/<string:username>/<int:index>", methods=["GET"])
def delete_med_based_on_index(username, index):
    user = db.readUserData(username)
    meds = user["medicines"]
    med = meds.pop(index)

    db.writeUndo(med, index)

    user["medicines"] = meds

    if db.writeUserData(username, user):
        return jsonify({"code": 200, "msg": "success"})
    else:
        return jsonify({"code": 400, "msg": "failure"})


@app.route("/api/meds/undo/<string:username>")
def undo_med_based_on_index(username):
    undo = db.readUndo()
    idx = undo["idx"]
    med = undo["med"]
    user = db.readUserData(username)
    meds = user["medicines"]
    meds.insert(idx, med)
    user["medicines"] = meds

    if db.writeUserData(username, user):
        return jsonify({"code": 200, "msg": "success"})
    else:
        return jsonify({"code": 400, "msg": "failure"})


@app.route("/medsapi/infos/<string:username>", methods=["POST"])
def save_meds(username):
    content = request.json
    content = content["data"]

    user = db.readUserData(username)
    user["medicines"].extend(content)
    db.writeUserData(username, user)

    return jsonify({"code": 200, "message": f"success for {username}"})


# medicines_using is part of this as well
@app.route("/api/database/medicines/<string:username>", methods=["GET"])
def get_medicines(username):
    user = db.readUserData(username)
    return jsonify(
        {"medicines": user["medicines"], "medicines_using": user["medicines_using"]}
    )


@app.route("/myhealthboxapi/search/<string:name>")
def serach_product(name):
    url = "https://myhealthbox.p.rapidapi.com/search/fulltext"

    querystring = {"q": name, "c": "us", "l": "en", "limit": "10", "from": "0"}

    headers = {
        "X-RapidAPI-Key": f"{os.getenv('RAPID')}",  # i'll give you it later
        "X-RapidAPI-Host": "myhealthbox.p.rapidapi.com",
    }

    response = requests.get(url, headers=headers, params=querystring)

    if response.json()["total_results"] >= 1:
        firstResultID = response.json()["result"][0]["product_id"]
        one_product_info_url = "https://myhealthbox.p.rapidapi.com/product/info"
        querystring = {"product_id": firstResultID}
        response = requests.get(
            one_product_info_url, headers=headers, params=querystring
        )
        js = response.json()
        js["code"] = 200
        return jsonify(js)

    else:
        return jsonify({"code": "400", "msg": "search invalid - no results returned"})


@app.route("/chatbot/sendres/<string:username>/<string:message>")
def chat(username, message):
    firstInput = cb.clf
    secondInput = cb.cols

    session = db.readSession(username)
    step = session["step"]
    if step == 0:
        mp = cb.tree_without_inputs_return_question(firstInput, secondInput)
        db.incrementSesStep(username)
        return jsonify(mp["msg"])
    elif step == 1:
        session["copy_disease_input"] = message
        db.writeSession(username, session)
        mp = cb.tree_without_inputs_return_question(
            firstInput, secondInput, session["copy_disease_input"]
        )
        if mp["code"] == "success":
            db.incrementSesStep(username)
            return jsonify(mp["msg"])
        else:
            return jsonify(mp["msg"])
    elif step == 2:
        session["copy_conf_inp"] = message
        db.writeSession(username, session)
        mp = cb.tree_without_inputs_return_question(
            firstInput,
            secondInput,
            session["copy_disease_input"],
            session["copy_conf_inp"],
        )
        db.incrementSesStep(username)
        db.clearSession(username)
        return jsonify(mp["msg"])
    # elif step == 3:
    #     session["copy_num_days"] = message
    #     db.writeSession(username, session)
    #     mp = cb.tree_without_inputs_return_question(
    #         firstInput,
    #         secondInput,
    #         session["copy_disease_input"],
    #         session["copy_conf_inp"],
    #         session["copy_num_days"],
    #     )
    #     db.incrementSesStep(username)
    #     return jsonify(mp["msg"])
    # elif step == 4:
    #     session["copy_symptoms_list_yes_no"] = message
    #     db.writeSession(username, session)
    #     mp = cb.tree_without_inputs_return_question(
    #         firstInput,
    #         secondInput,
    #         session["copy_disease_input"],
    #         session["copy_conf_inp"],
    #         session["copy_num_days"],
    #         session["copy_symptoms_list_yes_no"],
    #     )
    #     db.incrementSesStep(username)

    #     db.clearSession(username)

    #     return jsonify(mp["msg"])

    return jsonify("")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5600, debug=True)
