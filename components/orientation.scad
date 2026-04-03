/**
 * Apply LEF/DEF style orientation changes specified by a text flag.
 * See LEF/DEF 5.8 Language Reference manual page 244
 * There is currently no way in OpenSCAD to determine bounding box
 * to do automatic translation, you will need to provide it.
 */
module orient(bounds, orient) {
    width = bounds[0];
    height = bounds[1];
    if (orient == "N" || orient == "R0"){
        children();
    } else if (orient == "S" || orient == "R180"){
        translate([width, height, 0])
        rotate([0, 0, 180])
        children();
    } else if (orient == "E" || orient == "R270") {
        translate([0, width, 0])
        rotate([0, 0, 270])
        children();
    } else if (orient == "W" || orient == "R90") {
        translate([height, 0, 0])
        rotate([0, 0, 90])
        children();
    } else if (orient == "FN" || orient == "MY"){
        translate([width, 0, 0])
        mirror([1, 0, 0])
        children();
    } else if (orient == "FS" || orient == "MX"){
        translate([0, height, 0])
        mirror([0, 1, 0])
        children();
    } else if (orient == "FE" || orient == "MY90" || orient == "MYR90") {
        translate([height, width, 0])
        rotate([0, 0, 270])
        mirror([0, 1, 0])
        children();
    } else if (orient == "FW" || orient == "MX90" || orient == "MXR90") {
        translate([0, 0, 0])
        rotate([0, 0, 270])
        mirror([1, 0, 0])
        children();
    } else {
        assert(false, concat("Unknown rotation applied", orient));
    }
}
