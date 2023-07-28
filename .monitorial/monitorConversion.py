
import yaml
from typing import List
import os
from models import macro_details, macro_argument

def read_file(path):
    with open(path) as f:
        return f.read()

def write_file(path, contents):
    with open(path, "w") as f:
        f.write(contents)
        
def get_folder_items(path, macros:List[macro_details]):
    items = os.listdir(path)
    for item in items:
        if os.path.isfile(f"{path}\{item}"):
            get_file_items(f"{path}\{item}", macros)
        else:
            get_folder_items(f"{path}\{item}", macros)


def get_default_value(macro_name, argument_name, argument_type, contents):

    lines  = contents.split("\n")
    name = f"{{% macro {macro_name}"
    for line in lines:
       if line.startswith(name):
            working_line = line.replace(f"{name}(", "").replace(") -%}", "").replace(" = ", "=")
            #print(f"{macro_name} - {argument_name} - {working_line}")
            while working_line.strip().startswith(f"{argument_name},") == False and working_line.strip().startswith(f"{argument_name}=") == False and working_line != argument_name :
                working_line = working_line[1:]

            if working_line.strip().startswith(f"{argument_name},"):
                defaultValue = ""
            elif working_line.strip().startswith(f"{argument_name}="):
                if argument_type.startswith("List"):
                    data  =working_line.split("]")[0].strip()
                    defaultValue = data.split("=")[1]
                    defaultValue = f"{defaultValue}]"
                else:
                    data = working_line.split(",")[0].strip()
                    defaultValue = data.split("=")[1].replace("\"", "")
            else:
                defaultValue = ""

            return defaultValue


            break

    return ""

def get_macro_content(path, file_name):
    contents = read_file(f"{os.path.dirname(path)}\\{file_name}.sql")
    if "--<prereq>" in contents:
        prereq_statements:List[str] = []
        full_sql = contents.split("\n")
        for line in full_sql:
            if "--<prereq>" in line:
                prereq_statements.append(line)

        for line in prereq_statements:
            contents = contents.replace(line, "")

    return contents

def get_macro_prereqs(path, file_name):
    contents = read_file(f"{os.path.dirname(path)}\\{file_name}.sql")
    prereq_statements:List[str] = []
    return_statements:List[str] = []
    if "--<prereq>" in contents:
        full_sql = contents.split("\n")
        for line in full_sql:
            if "--<prereq>" in line:
                prereq_statements.append(line)

        for line in prereq_statements:
            return_statements.append(line.replace("--<prereq>", "").replace(";",""))

    return return_statements


def get_file_items(path, macros:List[macro_details]):
    if path.endswith(".yml"):
        with open(path, 'r') as stream:
            data = yaml.safe_load(stream)
            if "macros" in data:
                for macro in data['macros']:
                    details = macro_details()
                    details.name = macro['name']
                    details.description = macro['description']

                    if os.path.basename(os.path.dirname(os.path.dirname(path))) == "macros":
                        details.classification =  os.path.basename(os.path.dirname(path))
                        details.grouping = ""
                    else:
                        details.classification = f"{os.path.basename(os.path.dirname(os.path.dirname(path)))}"
                        details.grouping = os.path.basename(os.path.dirname(path))

                    if "monitorial" in macro:
                        if "version" in macro['monitorial']:
                            details.version = macro['monitorial']['version']
                        else:
                            details.version = "1.0.0"

                        if "defaults" in macro['monitorial']:
                            if 'schedule' in macro['monitorial']['defaults']:
                                details.schedule = macro['monitorial']['defaults']['schedule']
                            if 'severity' in macro['monitorial']['defaults']:
                                details.severity = macro['monitorial']['defaults']['severity']
                            if 'message' in macro['monitorial']['defaults']:
                                details.message = macro['monitorial']['defaults']['message']
                            if 'environment' in macro['monitorial']['defaults']:
                                details.environment = macro['monitorial']['defaults']['environment']
                            if 'message_type' in macro['monitorial']['defaults']:
                                details.message_type = macro['monitorial']['defaults']['message_type']
                        else:
                            details.schedule = "0 8 * * *"
                            details.severity = "warning"
                            details.message = "No message provided"
                            details.environment = "prod"
                            details.message_type = details.classification
                            
                        if "column_filters" in macro['monitorial']:
                            if "limit_datatypes" in macro['monitorial']['column_filters']:
                                details.limit_datatypes = macro['monitorial']['column_filters']['limit_datatypes']
                    else:
                        details.version = "1.0.0"
                        details.schedule = "0 8 * * *"
                        details.severity = "warning"
                        details.message = "No message provided"
                        details.environment = "prod"
                        details.message_type = details.classification

                    details.contents = get_macro_content(path, details.name)
                    details.prerequisits = get_macro_prereqs(path, details.name)
                    details.arguments = []
                    if "arguments" in macro:
                        for argument in macro['arguments']:
                            default = get_default_value(details.name, argument["name"], argument['type'], details.contents)
                            details.arguments.append(macro_argument(argument['name'], argument['description'], argument['type'], default))

                    macros.append(details)


