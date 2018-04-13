#!/bin/python3

from optparse import OptionParser
import os
import pathlib
import re

parser = OptionParser()
parser.add_option("-i", "--input-dir", dest="dir", help="input directory")
(options, args) = parser.parse_args()

input = options.dir

class Vhost:

    def __init__(self):
        input1 = input
        self.input = input

    def job(self, queueElem):
        print(queueElem)

    def list(self):
        return os.listdir(pathlib.Path('../', self.input))

    def cleanLinks(self, fileList):
        for file in fileList:
            myPath = pathlib.Path('../', 'data', file)
            if len(open(myPath).readlines(  )) <= 1:
                os.remove(myPath)

    def readFile(self, fileList):
        for file in fileList:
            fileContent = []
            myPath = str(pathlib.Path('../', 'data', file))
            content = open(myPath, 'r')
            for line in content:
                cleanedLine = re.sub(r'\s{2,200}', '', line)
                cleanedLine = re.sub(r'<\W*>', '', line)
                splitedLine = cleanedLine.strip().split()
                for i in splitedLine:
                    print(i)
            content.close()

vhost = Vhost()
vhostList = vhost.list()
vhost.cleanLinks(vhostList)
vhostCat = vhost.readFile(vhostList)
