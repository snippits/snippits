#!/usr/bin/env python3

import json
import glob
from pprint import pprint

process_list = glob.glob("/tmp/snippit/phase/*")
for process_path in process_list:
    with open(process_path + '/process_info') as data_file:
        data = json.load(data_file)
        print('{:>5} - {}'.format(data["pid"], data["Name"]))

