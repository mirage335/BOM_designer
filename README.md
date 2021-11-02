Copyright (C) 2020 mirage335
See the end of the file for license conditions.
See license.txt for BOM_designer license conditions.

Hierarchical BOM using simple text files and shell script. Multiplies and adds all ITEM entries in 'csv' format (comma separated values) from all files with extensions '*.lbom.csv', '*.lbom.txt', '*.lbom' . Compiles a consolidated list.


# Usage

_BOM_designer_geometry ./

*) Consolidated output 'qty' fields are normally '0'.

*) Descriptive 'dst' (distributor),'mark' (marketing name),'provider' (arbitrary name for a supplier),'path' (location of geometry/CAD model file) may be empty.
*) Descriptive fields will be filled from any entry with this entry and matching 'item' field.
*) Conventionally, 'providers.lbom.txt' has 'qty' '0' ITEM entries with descriptive fields.
*) Conventionally, 'overides.lbom.txt' has 'qty' '0' ITEM entries which *force* descriptive fields (ie. change to alternate suppliers as desired).

*) COMMENTS are always ignored.
*) MULTIPLIER converts 'qty' to 'mult'.
*) BUNDLE entries are not consolidated - only 'mult' is updated.
*) MULTIPLIER at files corresponding to BUNDLE entries should be edited to match.
*) BUNDLE is only for user reference (equivalent to comments) and is not automatically consolidated.
*) ITEM entries are automatically consolidated.

*) ITEM/BUNDLE names must be unique.
*) Conventionally, ITEM/BUNDLE names are file names matching a geometry/CAD model file name basename.

Input format illustrated by example available under '_lib/example' .

A "bins.ods" spreadsheet is provided for manual conversion to 'csv' (comma separated values), to easily paste columns of data from other sources (eg. FreeCAD A2Plus BOM documents).

# Design

CSV format is intended to be compatible with LibreOffice Calc .

Cost is not multiplied automatically by this tool.

File extension '*lbom*' is intended as acronym for 'leveled bill-of-materials'.


Other 'magic sequences' were considered.

#^@magic^@#-start/stop-blockName
#^@blockName-start/stop-magic^@#


Scripting language 'bash' was chosen for similar reasons as for Ubiquitous Bash itself. Portability to a wide variety of existing operating systems and distributions thereof was the most important consideration. Efficient use of widely available, robust, pre-existing standalone programs (eg. 'find', 'cut', 'sort', 'uniq') was a significant feature.
Perl was the only other language thoroughly considered. While the text processing features may be more powerful, there is not yet a clear need for them, and new major versions in progress of 'perl' raise stability concerns. Similar structure to 'bash' allows the possibility of a future port to well structured 'perl' code if additionally functionality required at some point warrants the perceived risk.
C, C++, Go, Java, and similar, were considered unnecessarily risky due to any possibility of machine-specific dependencies.
Python was ruled out immediately due to ongoing portability and stability concerns.


BUNDLE quantities are ignored by default - this can be changed by adding BUNDLE to the relevant line of code at 'core_bom_consolidate.sh'.
' if ( [[ "$currentBlock_bom" == 'ITEM' ]] ) && [[ "$bom_item" != "" ]] '


# Future Work

Code might be simplified with better use of object-oriented programming techinque. Which specifically is not to suggest chosing the programming language for unnecessary object oriented features.

HTML table generator may be useful.

Automatic generation of separate output files for each distributor may be useful.


__Copyright__
This file is part of BOM_designer.

BOM_designer is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

BOM_designer is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with BOM_designer.  If not, see <http://www.gnu.org/licenses/>.
