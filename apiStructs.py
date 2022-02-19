#================================================================================
# Author: Alex Creencia
# Filename: Data Class Structs
# Description: Contains all the data structures used to hold data parsed from 
#              JSON's, and vice versa. 
# TEST FILE: MAY NOT BE NEEDED FOR FINAL FILE
#================================================================================


# Helpful link: https://stackoverflow.com/questions/51286748/make-the-python-json-encoder-support-pythons-new-dataclasses 

# requires command "pip3 install marshmallow-dataclass"

from dataclasses import field
import marshmallow_dataclass
from marshmallow_dataclass import dataclass
import string, json


# Landmark data class/struct
# members                  : Description 
#  - landmarkName          : A string that holds the name of the landmark (which is also the uniqueID in the database. Eg: "MacEwan")
#  - landmarkAddress       : The address of the landmark (e.g: "104th Street")
@dataclass
class Landmark:
    landmarkName: str = field(metadata={"required": True})
    landmarkAddress: str







