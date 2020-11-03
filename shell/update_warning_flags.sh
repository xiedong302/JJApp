#!/usr/bin/env python
#coding=utf-8

import os

WARNING_FLAGS = [
	'-Wno-unused-property-ivar',
    '-Wno-nonnull',
    '-Wno-incomplete-umbrella',
    '-Wno-shorten-64-to-32',
    '-Wno-unused-variable',
    '-Wno-documentation',
]

PATH = os.path.dirname(os.path.realpath(__file__))

print('PATH='PATH)

for file in os.listdir(PATH):

	if os.path.isdir(file) and file.startswith('JJ'):
		pbxproj = os.path.join(PATH, file, file + '.xcodeproj', 'project.pbxproj')

		if os.path.exists(pbxproj):
			content = ''

			print('Updating ' + pbxproj)

			# with open(pbxproj, 'r') as file:
			# 	warning_flags_section_start = False

			# 	for line in file:
			# 		if line.find('WARNING_CFLAGS = (') != -1:
			# 			warning_flags_section_start = True
			# 			content += line
			# 			tab_count = line.count('\t') + 1

			# 			for flag in WARNING_FLAGS:
			# 				for index in range(0, tab_count):
			# 					content += '\t'
			# 				content += '"' + flag + '",\n'
			# 		elif warning_flags_section_start:
			# 			if line.find(');') != -1:
			# 				warning_flags_section_start = False
			# 				content += line
			# 		else:
			# 			content += line

			# with open(pbxproj, 'w') as file:
			# 	file.write(content)

print('All done!!!')
