#!/bin/python3

from optparse import OptionParser

parser = OptionParser()
parser.add_option("-i", "--input-dir", dest="dir", help="input directory")
(options, args) = parser.parse_args()

input = options.dir

class Test:

    def __init__(self):
        self.input = input

    def display(self):
        print(self.input)

instance = Test()
instance.display()
