"""A parametric part. Change a number, save, and the OCP CAD Viewer updates.

`uv run part.py` writes <folder>.stl and <folder>.step next to this file;
open the STL in Bambu Studio. Docs: https://build123d.readthedocs.io
"""

from pathlib import Path

from build123d import *
from ocp_vscode import show
from ocp_vscode.comms import get_port

# ---- Parameters (mm) -------------------------------------------------------
length = 60
width = 30
thickness = 4
corner_radius = 3
hole_diameter = 3.4  # M3 clearance
hole_spacing = 40

# ---- Model -----------------------------------------------------------------
with BuildPart() as part:
    # Top face at z=0, so holes cut down through the whole plate.
    Box(length, width, thickness, align=(Align.CENTER, Align.CENTER, Align.MAX))
    fillet(part.edges().filter_by(Axis.Z), radius=corner_radius)
    with Locations((-hole_spacing / 2, 0), (hole_spacing / 2, 0)):
        Hole(hole_diameter / 2)

# ---- Export & show ---------------------------------------------------------
here = Path(__file__).parent
export_stl(part.part, str(here / f"{here.name}.stl"))
export_step(part.part, str(here / f"{here.name}.step"))
print(f"Exported {here.name}.stl and {here.name}.step ({part.part.volume:.0f} mm³)")

if get_port():  # only when the OCP CAD Viewer is open
    show(part)
