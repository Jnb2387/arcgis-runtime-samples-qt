// [WriteFile Name=GraphicsOverlay_DictionaryRenderer, Category=DisplayInformation]
// [Legal]
// Copyright 2016 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// [Legal]

import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.XmlListModel 2.0
import Esri.ArcGISRuntime 100.0
import Esri.ArcGISExtras 1.1

Rectangle {
    width: 800
    height: 600

    property real scaleFactor: System.displayScaleFactor
    property url dataPath: System.userHomePath + "/ArcGIS/Runtime/Data"

    // Create MapView that contains a Map with the Topographic Basemap, as well as a GraphicsOverlay
    // for the military symbols.
    MapView {
        id: mapView
        anchors.fill: parent
        Map {
            id: map
            BasemapTopographic {}
        }

        //! [Apply Dictionary Renderer Graphics Overlay QML]
        GraphicsOverlay {
            id: graphicsOverlay

            DictionaryRenderer {
                DictionarySymbolStyle {
                    specificationType: "mil2525d"
                    styleLocation: dataPath + "/styles/mil2525d.stylx"
                }
            }
        }
        //! [Apply Dictionary Renderer Graphics Overlay QML]
    }

    ProgressBar {
        id: progressBar_loading
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            margins: 5 * scaleFactor
        }
        indeterminate: true
    }

    // Use XmlListModel to parse the XML messages file.
    XmlListModel {
        id: xmlParser
        source: dataPath + "/xml/Mil2525DMessages.xml"
        query: "/messages/message"

        // These are the fields we need for MIL-STD-2525D symbology.
        XmlRole { name: "_control_points"; query: "_control_points/string()" }
        XmlRole { name: "_wkid"; query: "_wkid/number()" }
        XmlRole { name: "identity"; query: "identity/number()" }
        XmlRole { name: "symbolset"; query: "symbolset/number()" }
        XmlRole { name: "symbolentity"; query: "symbolentity/number()" }
        XmlRole { name: "echelon"; query: "echelon/number()" }
        XmlRole { name: "specialentitysubtype"; query: "specialentitysubtype/number()" }
        XmlRole { name: "indicator"; query: "indicator/number()" }
        XmlRole { name: "modifier2"; query: "modifier2/number()" }
        XmlRole { name: "uniquedesignation"; query: "uniquedesignation/string()" }
        XmlRole { name: "additionalinformation"; query: "additionalinformation/string()" }

        onStatusChanged: {
            if (status === XmlListModel.Ready) {
                var bbox;
                for (var i = 0; i < count; i++) {
                    var element = get(i);
                    var wkid = element._wkid;
                    if (!wkid) {
                        // If _wkid was absent, use WGS 1984 (4326) by default.
                        wkid = 4326;
                    }
                    var pointStrings = element._control_points.split(";");
                    var sr = ArcGISRuntimeEnvironment.createObject("SpatialReference", { wkid: wkid });
                    var geom;
                    if (pointStrings.length === 1) {
                        // It's a point
                        var pointBuilder = ArcGISRuntimeEnvironment.createObject("PointBuilder");
                        pointBuilder.spatialReference = sr;
                        var coords = pointStrings[0].split(",");
                        pointBuilder.setXY(coords[0], coords[1]);
                        geom = pointBuilder.geometry;
                    } else {
                        var builder = ArcGISRuntimeEnvironment.createObject("MultipointBuilder");
                        builder.spatialReference = sr;

                        for (var ptIndex = 0; ptIndex < pointStrings.length; ptIndex++) {
                            var coords = pointStrings[ptIndex].split(",");
                            builder.points.addPointXY(coords[0], coords[1]);
                        }
                        geom = builder.geometry;
                    }
                    if (geom) {
                        // Get rid of _control_points and _wkid. They are not needed in the graphic's
                        // attributes.
                        element._control_points = undefined;
                        element._wkid = undefined;

                        var graphic = ArcGISRuntimeEnvironment.createObject("Graphic", { geometry: geom });
                        graphic.attributes.attributesJson = element;
                        graphicsOverlay.graphics.append(graphic);

                        if (bbox) {
                            bbox = GeometryEngine.unionOf(bbox, graphic.geometry.extent);
                        } else {
                            bbox = geom.extent;
                        }
                    }
                }

                // Zoom to graphics
                if (bbox)
                   mapView.setViewpointGeometryAndPadding(bbox, 20);

                progressBar_loading.visible = false;
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border {
            width: 0.5 * scaleFactor
            color: "black"
        }
    }
}
