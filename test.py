import subprocess
import unittest

class TestDictionary(unittest.TestCase):
    def run_program(self, input_data):
        path = './lab2'
        result = subprocess.run([path], input=input_data, text=True, capture_output=True)
        return result.stdout, result.stderr

    def test_1(self):
        input_data = "next word"
        expected_out = "next"
        expected_err = ""
        output, error = self.run_program(input_data)
        self.assertEqual(output.strip(), expected_out)
        self.assertEqual(error.strip(), expected_err)

    def test_2(self):
        input_data = "testtesttest test " * 27
        expected_out = ""
        expected_err = "Buffer overflow"
        output, error = self.run_program(input_data)
        self.assertEqual(output.strip(), expected_out)
        self.assertEqual(error.strip(), expected_err)

    def test_3(self):
        input_data = "oleg"
        expected_out = "Privet!"
        expected_err = ""
        output, error = self.run_program(input_data)
        self.assertEqual(output.strip(), expected_out)
        self.assertEqual(error.strip(), expected_err)

    def test_4(self):
        input_data = "not true"
        expected_out = ""
        expected_err = "Word not found"
        output, error = self.run_program(input_data)
        self.assertEqual(output.strip(), expected_out)
        self.assertEqual(error.strip(), expected_err)

if __name__ == '__main__':
    unittest.main()
