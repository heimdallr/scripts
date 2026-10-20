import os

def configure_boost(recipe):
    recipe.options["boost"].shared = True
    recipe.options["boost"].header_only = True
    recipe.options["boost"].error_code_header_only = True

def configure_xercesc(recipe):
    recipe.options["xerces-c"].char_type = 'char16_t'
    recipe.options["xerces-c"].shared = False
    recipe.options["xerces-c"].network = False
    if recipe.settings.os == "Linux":
        recipe.options["xerces-c"].transcoder = "icu"

def configure_icu(recipe):
    recipe.options["icu"].shared = True
    recipe.options["icu"].with_extras = False
    recipe.options["icu"].with_samples = False

def configure_libjxl(recipe):
    recipe.options["libjxl"].shared = False

def configure_djvulibre(recipe):
    recipe.options["djvulibre"].shared = True

def configure_poppler(recipe):
    recipe.options["poppler"].shared = False

def configure_libxml2(recipe):
    recipe.options["libxml2"].shared = False

def configure_zlib(recipe):
    recipe.options["zlib"].shared = False

def configure_sqlite3(recipe):
    recipe.options["sqlite3"].threadsafe = 0
    recipe.options["sqlite3"].enable_fts5 = True
    
def run_local_recipe(recipe, local_recipe_path, lib, version):
    local_recipe = os.path.normpath(os.path.join(local_recipe_path, lib, version))
    if not os.path.isdir(local_recipe):
        raise FileNotFoundError(f"Cannot find local {lib} recipe: {local_recipe}")
    recipe.run(f"conan export {local_recipe} --version={version}")
