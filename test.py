import subprocess
import unittest

class TestDictionary(unittest.TestCase):
    def run_program(self, input_data):
        path = './main'
        result = subprocess.run([path], input=input_data, text=True, capture_output=True)
        return result.stdout, result.stderr

    def test_next_word(self):
        input_data = "next word"
        expected_out = "next"
        expected_err = ""
        output, error = self.run_program(input_data)
        self.assertEqual(output.strip(), expected_out)
        self.assertEqual(error.strip(), expected_err)

    def test_vsem_privet(self):
        input_data = "vsem privet, ya tut"
        expected_out = "i tebe privet"
        expected_err = ""
        output, error = self.run_program(input_data)
        self.assertEqual(output.strip(), expected_out)
        self.assertEqual(error.strip(), expected_err)

    def test_empty(self):
        input_data = ""
        expected_out = "pusto"
        expected_err = ""
        output, error = self.run_program(input_data)
        self.assertEqual(output.strip(), expected_out)
        self.assertEqual(error.strip(), expected_err)

    def test_space(self):
        input_data = " "
        expected_out = "nemnogo pusto"
        expected_err = ""
        output, error = self.run_program(input_data)
        self.assertEqual(output.strip(), expected_out)
        self.assertEqual(error.strip(), expected_err)

    def test_buffer_overflow(self):
        input_data = "eto perepolnenie " * 15
        expected_out = ""
        expected_err = "Buffer overflow"
        output, error = self.run_program(input_data)
        self.assertEqual(output.strip(), expected_out)
        self.assertEqual(error.strip(), expected_err)

    def test_oleg(self):
        input_data = "oleg"
        expected_out = "Privet!"
        expected_err = ""
        output, error = self.run_program(input_data)
        self.assertEqual(output.strip(), expected_out)
        self.assertEqual(error.strip(), expected_err)

    def test_first_item(self):
        input_data = "first item"
        expected_out = "the first one"
        expected_err = ""
        output, error = self.run_program(input_data)
        self.assertEqual(output.strip(), expected_out)
        self.assertEqual(error.strip(), expected_err)

    def test_ne_oleg(self):
        input_data = "ne oleg"
        expected_out = ""
        expected_err = "Word not found"
        output, error = self.run_program(input_data)
        self.assertEqual(output.strip(), expected_out)
        self.assertEqual(error.strip(), expected_err)

if __name__ == '__main__':
    unittest.main()
