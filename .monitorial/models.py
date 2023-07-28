from typing import List
import json

class macro_argument():
    name:str = ""
    description:str = ""
    type:str = ""
    defaultValue:str = ""
    defaultValues:List[str] = []
    
    def __init__(self, name:str , description:str , type:str , default:str) -> None:
        self.name = name
        self.defaultValue = default
        self.description = description
        self.type = type
        
        if default.startswith("["):
            self.defaultValues = []
            for item in default.replace("[", "").replace("]", "").split(","):
                self.defaultValues.append(item.strip().replace("\"", ""))

        pass
    
    def to_object(self):
        data = {}
        data["name"] = self.name
        data["description"] = self.description
        data["type"] = self.type
        data["defaultValue"] = self.defaultValue
        data["defaultValues"] = self.defaultValues
        
        return data

class macro_details():
    grouping:str = ""
    name:str
    description:str
    version:str = "1.0.0"
    arguments:List[macro_argument] = []
    contents:str = ""
    prerequisits:List[str] = []
    enabled:bool = True
    schedule:str = ""
    severity:str = ""
    message:str = ""
    classification:str = ""
    environment:str = ""
    message_type:str = ""
    limit_datatypes:List[str] = []

    def __init__(self) -> None:
        self.classification = ""
        self.message_type = ""
        self.version= 1
        self.schedule = ""
        self.severity = ""
        self.message = ""
        self.environment = ""
        self.grouping= ""
        self.name = ""
        self.description = ""
        self.arguments = []
        self.contents = ""
        self.enabled = True
        self.prerequisits = []
        self.limit_datatypes = []
        
        pass
    
    def to_object(self):
        data = {}
        data["id"] = self.name
        data["defaults"] = {}
        data["defaults"]["schedule"] = self.schedule
        data["defaults"]["severity"] = self.severity
        data["defaults"]["message"] = self.message
        data["defaults"]["environment"] = self.environment
        data["defaults"]["message_type"] = self.message_type
        
        data["columnFilters"] = {}
        data["columnFilters"]["limit_datatypes"] = []
        for datatype in self.limit_datatypes:
            data["columnFilters"]["limit_datatypes"].append(datatype)

        data["classification"] = self.classification
        data["grouping"] = self.grouping
        data["description"] = self.description
        data["version"] = self.version

        data["macro"] = {}
        data["macro"]["contents"] = self.contents
        data["macro"]["prerequisits"] = self.prerequisits
        data["macro"]["arguments"] = []
        for argument in self.arguments:
            data["macro"]["arguments"].append(argument.to_object())
        data["enabled"] = self.enabled
        return data
    
    def to_string(self):
        return json.dumps(self.to_object(), indent=4, sort_keys=True, default=str)