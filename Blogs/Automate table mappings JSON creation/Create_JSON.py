import json
import csv
import os

data = {}
line_count = 0
data['rules'] = []

def writeJSON():
    with open('automated_json.json', 'w') as outfile:
        json.dump(data, outfile)


def createJSON(csvfile,action):
    global line_count
    with open(csvfile) as file:
       csv_reader = csv.reader(file, delimiter=',')

       for row in csv_reader:
           counter = str(line_count + 1)
           data['rules'].append({
               "rule-type": "selection",
               "rule-id": counter,
               "rule-name": counter,
               "object-locator": {
                   "schema-name": row[0],
                   "table-name": row[1]
               },
               "rule-action": action
           })
           line_count += 1


if __name__ == "__main__":
    print("This program expects a folder location from the user. ")
    print("The folder can have 2 different types of files in csv format.")
    print("The file types are include table list and exclude table list.")
    print(" ")
    print("The file name should start with include or exclude to indicate "
          "whether the content of a particular file has to included or excluded.")
    print(" ")
    print("Both include and exclude files should contain schema name and the table name "
          "to be included or excluded separated by comma.")
    print("It is not necessary to have both include and exclude files.")
    print(" ")

    File_Location = raw_input("Enter the Folder location: ")
    if("/" in File_Location):
        separater = "/"
    else:
        separater = "\\"
    listOfFiles = os.listdir(File_Location)
    for entry in listOfFiles:
        if (entry.startswith("include")):
            createJSON(File_Location+separater+entry,"include")
        elif (entry.startswith("exclude")):
            createJSON(File_Location+separater+entry, "exclude")

    writeJSON()
