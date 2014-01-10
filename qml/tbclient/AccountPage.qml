import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "../js/storage.js" as DB
import "../js/main.js" as Script

MyPage {
    id: page;

    tools: ToolBarLayout {
        BackButton {}
        ToolButtonWithTip {
            toolTipText: internal.isEdit ? qsTr("OK") : qsTr("Edit");
            iconSource: "../gfx/"+(internal.isEdit?"ok":"edit")+constant.invertedString+".svg";
            onClicked: internal.isEdit = !internal.isEdit;
        }
    }

    title: qsTr("Account manager");

    QtObject {
        id: internal;

        property bool isEdit: false;

        function refreshModel(){
            view.model.clear();
            var acc = DB.loadAuthData();
            acc.forEach(function(item){
                            //id, name, BDUSS, passwd, portrait
                            view.model.append(item);
                        });
        }

        function changeAccount(index){
            var model = view.model.get(index);
            if (model.id === tbsettings.currentUid)
                return;
            if (Script.checkAuthData(model.id)){
                tbsettings.currentUid = model.id;
                signalCenter.clearLocalCache();
                signalCenter.userChanged();
            } else {
                removeAccount(index);
            }
        }

        function removeAccount(index){
            var uid = view.model.get(index).id;
            DB.deleteAuthData(uid);
            refreshModel();
            if (tbsettings.currentUid === uid){
                if (view.count > index){
                    changeAccount(index);
                } else if (view.count > 0){
                    changeAccount(0);
                } else {
                    logout();
                }
            }
        }

        function logout(){
            pageStack.pop(mainPage, true);
            tbsettings.currentUid = "";
            signalCenter.userLogout();
            signalCenter.clearLocalCache();
            signalCenter.needAuthorization(true);
        }
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
    }

    ListView {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        model: ListModel {}
        delegate: accountDel;
        footer: FooterItem {
            text: qsTr("Add new account");
            onClicked: signalCenter.needAuthorization(false);
        }
        Component {
            id: accountDel;
            AbstractItem {
                id: root;
                onClicked: internal.changeAccount(index);
                Image {
                    id: avatarImg;
                    anchors {
                        left: root.paddingItem.left;
                        top: root.paddingItem.top;
                        bottom: root.paddingItem.bottom;
                    }
                    width: height;
                    source: Script.getPortrait(portrait);
                }
                Row {
                    id: infoRow;
                    anchors {
                        right: root.paddingItem.right;
                        verticalCenter: parent.verticalCenter;
                    }
                    spacing: constant.paddingSmall;
                    Loader {
                        anchors.verticalCenter: parent.verticalCenter;
                        sourceComponent: model.id === tbsettings.currentUid
                                         ? currentActiveIcon : undefined;
                        Component {
                            id: currentActiveIcon;
                            Image {
                                source: "../gfx/ok"+constant.invertedString+".svg"
                            }
                        }
                    }
                    Loader {
                        visible: status === Loader.Ready;
                        anchors.verticalCenter: parent.verticalCenter;
                        sourceComponent: internal.isEdit ? removeButtonComp : undefined;
                        Component {
                            id: removeButtonComp;
                            Button {
                                platformInverted: tbsettings.whiteTheme;
                                iconSource: privateStyle.toolBarIconPath("toolbar-delete", platformInverted);
                                width: height;
                                onClicked: internal.removeAccount(index);
                            }
                        }
                    }
                }
                Text {
                    anchors {
                        left: avatarImg.right; right: infoRow.left;
                        margins: constant.paddingMedium;
                        verticalCenter: parent.verticalCenter;
                    }
                    font: constant.titleFont;
                    text: name;
                    color: constant.colorLight;
                    wrapMode: Text.Wrap;
                }
            }
        }
    }

    ScrollDecorator { flickableItem: view; platformInverted: tbsettings.whiteTheme; }

    onStatusChanged: {
        if (status === PageStatus.Active){
            internal.refreshModel();
            view.forceActiveFocus();
        }
    }
}
