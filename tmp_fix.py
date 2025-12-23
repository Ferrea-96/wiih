from pathlib import Path

def build_old_block():
    e_acute = '\\u00E9'
    return (
        "    switch (selectedFilterOption) {\n"
        "      case 'Red':\n"
        "        wineList.filterWinesByType('Red');\n"
        "        break;\n"
        "      case 'White':\n"
        "        wineList.filterWinesByType('White');\n"
        "        break;\n"
        "      case 'Orange':\n"
        "        wineList.filterWinesByType('Orange');\n"
        "        break;\n"
        f"      case 'Ros{e_acute}':\n"
        f"        wineList.filterWinesByType('Ros{e_acute}');\n"
        "        break;\n"
        "      case 'Sparkling':\n"
        "        wineList.filterWinesByType('Sparkling');\n"
        "        break;\n"
        "      case 'None':\n"
        "        wineList.clearFilter();\n"
        "        break;\n"
        "      default:\n"
        "        wineList.clearFilter();\n"
        "    }\n"
        "    WinesUtil.saveWines(wineList);\n"
    )

def build_new_block():
    return (
        "    switch (selectedFilterOption) {\n"
        "      case 'Red':\n"
        "        wineList.filterWinesByType('Red');\n"
        "        break;\n"
        "      case 'White':\n"
        "        wineList.filterWinesByType('White');\n"
        "        break;\n"
        "      case 'Orange':\n"
        "        wineList.filterWinesByType('Orange');\n"
        "        break;\n"
        "      case 'Ros\\u00E9':\n"
        "        wineList.filterWinesByType('Ros\\u00E9');\n"
        "        break;\n"
        "      case 'Sparkling':\n"
        "        wineList.filterWinesByType('Sparkling');\n"
        "        break;\n"
        "      case 'PetNat':\n"
        "        wineList.filterWinesByType('PetNat');\n"
        "        break;\n"
        "      case 'None':\n"
        "        wineList.clearFilter();\n"
        "        break;\n"
        "      default:\n"
        "        wineList.clearFilter();\n"
        "    }\n"
    )

path = Path('lib/pages/cellar_page.dart')
text = path.read_text()
old = build_old_block()
if old not in text:
    raise SystemExit('Expected switch block not found')
new = build_new_block()
path.write_text(text.replace(old, new))
