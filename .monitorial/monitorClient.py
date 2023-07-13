from azure.cosmos import exceptions, CosmosClient, DatabaseProxy, ContainerProxy
import json
import os

class MonitorUploadClient:
    client:CosmosClient
    database:DatabaseProxy
    container:ContainerProxy
    production:bool

    def __init__(self, production:bool = False) -> None:
        if os.path.isfile(".secrets.json") == False:
            raise Exception("No secrets file found")

        with open(".secrets.json", 'r') as file:
            data = json.load(file)

        if production:
            env = "production"
        else:
            env = "development"
        endpoint = data[env]["cosmos"]["endpoint"]
        key = data[env]["cosmos"]["key"]

        # Initialize the Cosmos client, database and container
        self.client = CosmosClient(endpoint, key)
        self.database = self.client.get_database_client("monitorial")
        self.container = self.database.get_container_client("monitors")
        print(f"Connected to Cosmos ... {endpoint}")
        pass

    def uploadMonitor(self, name, document):
        print(f"Uploading {name}")
        self.container.upsert_item(document)

