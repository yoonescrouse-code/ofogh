# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

import sys
import os
from datetime import datetime

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'OpenWrt Build Guide - BPI-R3 (MT7986)'
copyright = f'{datetime.now().year}, OpenWrt Build Documentation'
author = 'OpenWrt Builder'
release = '1.0.0'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.viewcode',
    'sphinx.ext.githubpages',
]

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

# Read the Docs theme
try:
    import sphinx_rtd_theme
    html_theme = 'sphinx_rtd_theme'
    # html_theme_path is no longer needed in newer versions of sphinx_rtd_theme
except ImportError:
    # Fallback to default theme if sphinx_rtd_theme is not installed
    html_theme = 'alabaster'
    print("Warning: sphinx_rtd_theme not found, using default 'alabaster' theme.")
    print("Install it with: pip install sphinx-rtd-theme")

html_static_path = ['_static']
html_logo = None
html_favicon = None

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_css_files = []

