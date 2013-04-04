import os
import re
import glob
import itertools


class Related(object):
    # Initializes the RelatedFiles object.
    #
    # file_path - the file to look related files for
    # patterns  - a dictionary of patterns in the following format:
    #               {"(.+)_controller.rb": ["*/the/paths/$1/**", "*/test/$1_controller_test.rb"]}
    #
    # The glob paths will have their $i replaced by the matched groups within the file name
    # matcher.
    def __init__(self, file_path, patterns, folders):
        self.__file_path = file_path
        self.__patterns = patterns
        self.__root = self.__root(folders)
        self.__files = []
        self.__descriptions = []
        self.__build()

    # # Retrieves a list of all related descriptions.
    def descriptions(self):
        return self.__descriptions

    # # Retrieves a list of all related files paths.
    def files(self):
        return self.__files

    # Builds a list with all related files and sets self.descriptions and
    # self.files.
    def __build(self):
        files = set()

        file_path = self.__to_posixpath(self.__file_path)

        # for each matching pattern
        for regex, paths in self.__patterns.iteritems():
            match = re.compile(regex).match(file_path)
            if match:
                # returns a flattened file list
                files.update(self.__files_for_paths(regex, match, paths))

        # sorts items
        files = list(files)
        files.sort()

        self.__files = files
        self.__descriptions = [self.__file_without_root(file) for file in files]

    # Returns the root folder for the given file and folders
    def __root(self, folders):
        for folder in folders:
            if self.__file_path.startswith(os.path.join(folder, "")):
                return folder

    # Retrieves a list of files fot the given match and paths
    def __files_for_paths(self, regex, match, paths):
        paths = [self.__replaced_path(match, path) for path in paths]

        files = [glob.glob(os.path.join(self.__root, path)) for path in paths]
        flattened = [self.__to_posixpath(path) for path in list(itertools.chain.from_iterable(files))]

        # Ignores current file
        if self.__file_path in flattened:
            flattened.remove(unicode(self.__file_path))

        return flattened

    # Retrieves the file name without the root part.
    def __file_without_root(self, file):
        return os.path.basename(self.__root) + file[len(self.__root):]

    # Retrieves a path with its interpolation vars replaces by the found groups
    # on match.
    def __replaced_path(self, match, path):
        replaced_path = path
        for i, group in enumerate(match.groups()):
            replaced_path = replaced_path.replace("$%s" % (i + 1), group)
        return replaced_path

    # Converts paths to posixpaths.
    def __to_posixpath(self, path):
        return re.sub("\\\\", "/", path)
