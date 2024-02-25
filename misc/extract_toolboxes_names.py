
import re


with open("products.txt", "r") as file:
    lines = file.read().splitlines()

print(lines)

regex = '#product.([^_]+[_]?[^_\s]*_Toolbox)'
toolboxes = re.findall(regex, str(lines))
toolboxes_list = " ".join(toolboxes)
print(toolboxes_list)
