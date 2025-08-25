import py7zr
import getpass
import os

ori = os.getcwd()
toWork = "/WorkPlace/<some>/"
folder = "<name>.7z"

passwordx = getpass.getpass("xPassword:")

os.chdir(toWork)

with py7zr.SevenZipFile(folder, 'r', password = passwordx) as archive:
    archive.extractall(path=".")

os.chdir(ori)