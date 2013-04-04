import unittest
import os
from related import *


class RelatedTest(unittest.TestCase):

    def test_descriptions_with_matches(self):
        self.assertEqual(self.__related().descriptions(), [
            "example1/app/helpers/examples_helper.rb",
            "example1/app/views/examples/index.html",
            "example1/app/views/examples/show.html",
            "example1/test/controllers/examples_controller_test.rb"
        ])

    def test_descriptions_without_matches(self):
        self.assertEqual(self.__related_without_match().descriptions(), [])

    def test_files_with_matches(self):
        self.assertEqual(self.__related().files(), [
            self.__expand("fixtures/example1/app/helpers/examples_helper.rb"),
            self.__expand("fixtures/example1/app/views/examples/index.html"),
            self.__expand("fixtures/example1/app/views/examples/show.html"),
            self.__expand("fixtures/example1/test/controllers/examples_controller_test.rb")
        ])

    def test_files_without_matches(self):
        self.assertEqual(self.__related_without_match().files(), [])

    def __patterns(self):
        return {
          ".+\/app\/controllers\/(.+)_controller.rb": ["app/views/$1/**", "app/helpers/$1_helper.rb"],
          ".+\/app\/(.+).rb": ["test/$1_test.rb"]
        }

    def __file(self):
        return self.__expand("fixtures/example1/app/controllers/examples_controller.rb")

    def __folders(self):
        return [self.__expand("fixtures/example1"), self.__expand("fixtures/example2")]

    def __expand(self, path):
        return os.path.join(os.path.dirname(os.path.realpath(__file__)), path)

    def __related(self):
        return Related(self.__file(), self.__patterns(), self.__folders())

    def __related_without_match(self):
        return Related("/should/not/match", self.__patterns(), self.__folders())

if __name__ == '__main__':
    unittest.main()
