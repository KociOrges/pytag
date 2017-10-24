b'This module needs Python 3.4.0 or newer'

# Special variables #
__version__ = '1.4'
version_string = "trytouploadhelloworld version %s" % __version__


# Internal modules #
__all__ = ['analysis', 'annotation', 'ontologies']
from trytouploadhelloworld.analysis import process
from trytouploadhelloworld.annotation import annotate_abstract
from trytouploadhelloworld.ontologies import extract_terms


