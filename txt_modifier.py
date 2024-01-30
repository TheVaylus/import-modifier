import re

# Specify the input file path and output file path
input_file_path = r"C:\Users\esjimenez\Desktop\_12test\test.txt"
output_file_path = r"C:\Users\esjimenez\Desktop\_12test\modified.txt"

# Specify the pattern to match
pattern = r"Set C_AccountNum = '\d+'"

# Read the content of the input file
with open(input_file_path, 'r') as input_file:
    content = input_file.read()

# Replace the specified part in each row
modified_content = re.sub(pattern, "Set C_AccountNum = NULL", content)

# Save the modified content back to the output file
with open(output_file_path, 'w') as output_file:
    output_file.write(modified_content)

print("Script executed successfully. Output saved to", output_file_path)
