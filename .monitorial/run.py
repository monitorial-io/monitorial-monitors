
from typing import List
import os
from models import macro_details, macro_argument
from monitorClient import MonitorUploadClient
import monitorConversion as mc


if __name__ == '__main__':
    os.system('cls' if os.name == 'nt' else 'clear')
    print("=================================")
    print("Starting Monitorial Upload Client")
    print("=================================")
    is_production_answer = "unknown"
    docs_only_answer = "unknown"
    generate_file_answer = "unknown"
    upload_answer = "unknown"

    while docs_only_answer.lower() not in ["y", "n"]:
        docs_only_answer = input('Do you only want to generate the documentation? (y/n) ')
    is_docs_only = docs_only_answer.lower() == "y"

    macros:List[macro_details] = []
    mc.get_folder_items(f"{os.path.dirname(os.getcwd())}\\macros", macros)

    if not os.path.exists(f"{os.getcwd()}\\json"):
        os.makedirs(f"{os.getcwd()}\\json")

    if is_docs_only == False:
        while generate_file_answer not in ["y", "n"]:
            generate_file_answer = input('Do you want to generate json output files? (y/n) ')
        file_output = generate_file_answer.lower() == "y"

        while upload_answer.lower() not in ["y", "n"]:
            upload_answer = input('Do you want to upload? (y/n) ')
        upload_output = upload_answer.lower() == "y"

        if upload_output:
            while is_production_answer.lower() not in ["y", "n"]:
                is_production_answer = input('Do you want to upload to production? (y/n) ')

            is_production = is_production_answer.lower() == "y"
            monitorClient = MonitorUploadClient(is_production)

        for macro in macros:
            if file_output:
                file = f"{os.getcwd()}\\json\\{macro.name}.json"
                mc.write_file(file, macro.to_string())
            if upload_output:
                monitorClient.uploadMonitor(macro.name, macro.to_object())

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

   #for group in groups:
    #    print(f"""### {group["name"].replace("_", " ").title()}\n\n{group['macros']}""")
