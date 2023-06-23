
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

def get_default_value(macro_name, argument_name, contents):

    lines  = contents.split("\n")
    name = f"{{% macro {macro_name}"
    for line in lines:
        if line.startswith(name):
            if "]," in line:
                data = line.replace(name, "").replace("-%}", "").replace("(", "").replace(")", "").split("],")
            elif "]" in line:
                data = line.replace(name, "").replace("-%}", "").replace("(", "").replace(")", "").split("]")
            else:
                data = line.replace(name, "").replace("-%}", "").replace("(", "").replace(")", "").split(",")

            for item in data:
                if item.strip().startswith(argument_name):
                    if("=" not in item):
                        return ""
                    else:
                        defaultValue = item.strip().split("=")[1].strip()
                        if defaultValue.startswith("["):
                            defaultValue = f"{defaultValue}]"
                        elif "," in defaultValue:
                                defaultValue = defaultValue.strip().split(",")[0].strip()

                        return defaultValue
                elif argument_name in item:
                    new_data = item.split(",")
                    for new_item in new_data:
                        if new_item.strip().startswith(argument_name):
                            if("=" not in new_item):
                                return ""
                            else:
                                defaultValue = new_item.strip().split("=")[1].strip()
                                if defaultValue.startswith("["):
                                    defaultValue = f"{defaultValue}]"

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

                    if "monitorial_defaults" in macro:
                        if 'schedule' in macro['monitorial_defaults']:
                            details.schedule = macro['monitorial_defaults']['schedule']
                        if 'severity' in macro['monitorial_defaults']:
                            details.severity = macro['monitorial_defaults']['severity']
                        if 'message' in macro['monitorial_defaults']:
                            details.message = macro['monitorial_defaults']['message']
                        if 'environment' in macro['monitorial_defaults']:
                            details.environment = macro['monitorial_defaults']['environment']
                        if 'message_type' in macro['monitorial_defaults']:
                            details.message_type = macro['monitorial_defaults']['message_type']
                    else:
                        details.schedule = "* 8 * * *"
                        details.severity = "warning"
                        details.message = "No message provided"
                        details.environment = "prod"
                        details.message_type = details.classification

                    details.contents = get_macro_content(path, details.name)
                    details.prerequisits = get_macro_prereqs(path, details.name)
                    details.arguments = []
                    if "arguments" in macro:
                        for argument in macro['arguments']:
                            default = get_default_value(details.name, argument["name"], details.contents)
                            details.arguments.append(macro_argument(argument['name'], argument['description'], argument['type'], default))

                    macros.append(details)


def get_folder_items(path, macros:List[macro_details]):
    items = os.listdir(path)
    for item in items:
        if os.path.isfile(f"{path}\{item}"):
            get_file_items(f"{path}\{item}", macros)
        else:
            get_folder_items(f"{path}\{item}", macros)


if __name__ == '__main__':
    macros:List[macro_details] = []
    get_folder_items(f"{os.path.dirname(os.getcwd())}\\macros", macros)
   
    
    if not os.path.exists(f"{os.getcwd()}\\json"):
        os.makedirs(f"{os.getcwd()}\\json")

    for macro in macros:
        file = f"{os.getcwd()}\\json\\{macro.name}.json"
        write_file(file, macro.to_string())
    
    groups = []
    for macro in macros:
        if not any(group["name"] == macro.classification for group in groups):
            group = {}
            group["name"] = macro.classification
            group["macros"] = "|name|description|\n|---|---|\n"
            groups.append(group)
            
    for macro in macros:
        for group in groups:
            if group["name"] == macro.classification:
                group["macros"] += f"|{macro.name}|{macro.description}|\n"
        
    for group in groups:
        print(f"""### {group["name"].replace("_", " ").title()}\n\n{group['macros']}""")
   