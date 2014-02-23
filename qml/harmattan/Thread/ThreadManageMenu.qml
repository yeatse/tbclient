import QtQuick 1.1
import com.nokia.meego 1.1
import "../Component"
import "../../js/main.js" as Script

AbstractDialog {
    id: root;

    property variant view: null;

    property QtObject internal: QtObject {
        function setTop(on){
            var opt = {
                set: on,
                word: view.forum.name,
                fid: view.forum.id,
                tid: view.thread.id
            }
            view.loading = true;
            var s = function(){ view.loading = false; signalCenter.showMessage(qsTr("Success")); }
            var f = function(err){ view.loading = false; signalCenter.showMessage(err); }
            Script.commitTop(opt, s, f);
        }

        function setGood(on, cid){
            var opt = {
                set: on,
                word: view.forum.name,
                fid: view.forum.id,
                tid: view.thread.id,
                cid: cid
            }
            view.loading = true;
            var s = function(){ view.loading = false; signalCenter.showMessage(qsTr("Success")); }
            var f = function(err){ view.loading = false; signalCenter.showMessage(err); }
            Script.commitGood(opt, s, f);
        }

        function getGoodList(){
            var opt = { word: view.forum.name }
            view.loading = true;
            var s = function(list){
                view.loading = false;
                var callback = function(cid){setGood(true, cid)};
                signalCenter.commitGoodList(list, callback);
            }
            var f = function(err){
                view.loading = false;
                signalCenter.showMessage(err);
            }
            Script.getGoodList(opt, s, f);
        }
    }

    titleText: page.title;
    contentList: [
        DialogItem {
            text: qsTr("Add to top");
            onClicked: internal.setTop(true);
        },
        DialogItem {
            text: qsTr("Remove from top");
            onClicked: internal.setTop(false);
        },
        DialogItem {
            text: qsTr("Add to goodlist");
            onClicked: internal.getGoodList();
        },
        DialogItem {
            text: qsTr("Remove from goodlist");
            onClicked: internal.setGood(false);
        }
    ]
}
