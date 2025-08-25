import py7zr
import getpass
import shutil
import os

ori = os.getcwd()
toWork = "/WorkPlace/<some>/"

filename = "<name>.7z"

passwordx = getpass.getpass("xPassword:")

folders = ["need1/","need2/"]

os.chdir(toWork)

with py7zr.SevenZipFile(filename, 'w', dereference=True, password = passwordx) as archive:
    archive.set_encrypted_header(True)
    for xf in folders:
        archive.writeall(xf)
        shutil.rmtree(xf)

os.chdir(ori)