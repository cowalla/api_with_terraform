import os
import sys
import zipfile


PROJECT_PATH = os.path.dirname(os.path.realpath(__file__))
PYTHON_VERSION = sys.version_info
PYTHON_ENV_PATH = os.environ['_'].rstrip('/bin/python')


def main(argv):
    lambda_name = argv[0]
    lambda_directory = os.path.join(PROJECT_PATH, 'lambda_handlers', lambda_name)

    if not os.path.exists(lambda_directory):
        raise OSError('"%s" does not exist' % lambda_directory)

    zipfile_path = os.path.join(lambda_directory, 'build.zip')

    # delete the current zipfile
    if os.path.exists(zipfile_path):
        os.remove(zipfile_path)

    site_packages_path = os.path.join(
        PYTHON_ENV_PATH,
        'lib/python{major}.{minor}/site-packages'.format(major=PYTHON_VERSION.major, minor=PYTHON_VERSION.minor)
    )

    # write all files in site packages to zip
    with zipfile.ZipFile(zipfile_path, 'w') as build_zip:
        for folderName, subfolders, filenames in os.walk(site_packages_path):
            for filename in filenames:
                # create complete filepath of file in directory
                filePath = os.path.join(folderName, filename)
                relativePath = os.path.relpath(filePath, site_packages_path)
                build_zip.write(filePath, arcname=relativePath)

        lambda_path = os.path.join(lambda_directory, 'lambda.py')
        build_zip.write(lambda_path, arcname="lambda.py")


if __name__ == '__main__':
    """
    When run from the command line, will create a new packaged 'build.zip'
    
    python package_lambda.py <lambda_folder_name>
    """
    main(sys.argv[1:])
