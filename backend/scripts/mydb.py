# from simplejsondb import Database
import json

# If database named 'db' doesn't exist yet, creates a new empty dict database
# database = Database("db.json", default=dict())

# Now, we can treat the database instance as a dictionary!
# database.data['Hello'] = 'Hola'
# database.data['Goodbye'] = 'Adios'
# print(database.data.values())   # dict_values(['Hola', 'Adios'])

# # put a dictionary as the value
# def write(key, value):
#     database.data[key] = value
#     database.save()

# def read_all():
#     return database.data


# def read(key):
#     return database.data[key]
def writeData(data):
    with open("db.json", "w") as openfile:
        json_object = json.dumps(data)
        openfile.write(json_object)


def readData():
    with open("db.json", "r") as openfile:
        json_object = json.load(openfile)
        return json_object


def readUserData(username: str):
    json_object = {}
    with open("db.json", "r") as openfile:
        json_object = json.load(openfile)
    try:
        return json_object[username]
    except Exception as e:
        print(e)
        return {}


def writeUserData(username: str, data):
    try:
        userData = readUserData(username)
        userData[username] = data

        with open("db.json", "w") as openfile:
            json_object = json.dumps(userData)
            openfile.write(json_object)

        return True
    except Exception as e:
        print(e)
        return False


def readUndo():
    with open("db_undo.json", "r") as openfile:
        json_object = json.load(openfile)
        return json_object


def writeUndo(med, idx):
    with open("db_undo.json", "w") as openfile:
        json_object = json.dumps({"med": med, "idx": idx})
        openfile.write(json_object)


# ------
def readAllSessions():
    with open("db_chat.json", "r") as f:
        j = json.load(f)
        return j


def writeSessionStep(username, step: int):
    j = readAllSessions()
    j[username]["step"] = step
    with open("db_chat.json", "w") as f:
        f.write(json.dumps(j))


def incrementSesStep(username):
    j = readAllSessions()
    j[username]["step"] += 1
    with open("db_chat.json", "w") as f:
        f.write(json.dumps(j))


def readSession(username):
    with open("db_chat.json", "r") as f:
        j = json.load(f)
        try:
            return j[username]
        except Exception as e:
            print(e)
            user_init = {
                "step": 0,
                "copy_disease_input": None,
                "copy_conf_inp": None,
                "copy_num_days": None,
                "copy_symptoms_list_yes_no": None,
            }
            writeSession(username, user_init)
            return user_init


def writeSession(username, data):
    j = readAllSessions()
    j[username] = data
    with open("db_chat.json", "w") as f:
        f.write(json.dumps(j))


def clearSession(username):
    user_init = {
        "step": 0,
        "copy_disease_input": None,
        "copy_conf_inp": None,
        "copy_num_days": None,
        "copy_symptoms_list_yes_no": None,
    }
    writeSession(username, user_init)


# writeData({"hello": "hello"})

# data = readData()
# print(data)

# if __name__ == "__main__":
