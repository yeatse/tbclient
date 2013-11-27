import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"

Item {
    id: root;
    
    property alias imageList: imageArea.imageList;
    
    anchors.bottom: parent.bottom;
    width: screen.width;
    height: screen.height < 480 ? 120 : 180;
    
    ToolBar {
        id: toolBar;
        y: root.height - height;
        opacity: 1;
        tools: ToolBarLayout {
            BackButton {}
        }
    }
    
    ImageArea {
        id: imageArea;
        y: root.height;
        opacity: 0;
    }

    VoiceArea {
        id: voiceArea;
        y: root.height;
        opacity: 0;
    }
    
    states: [
        State {
            name: "Image";
            PropertyChanges { target: toolBar; y: root.height; opacity: 0; }
            PropertyChanges { target: imageArea; y: 0; opacity: 1; }
        },
        State {
            name: "Voice";
            PropertyChanges { target: toolBar; y: root.height; opacity: 0; }
            PropertyChanges { target: voiceArea; y: 0; opacity: 1; }
        }
    ]
    
    transitions: [
        Transition {
            PropertyAnimation { properties: "y,opacity"; }
        }
    ]
}
