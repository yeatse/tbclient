import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    id: root;

    titleText: "应用列表";

    content: Item {
        width: parent.width;
        height: Math.min(root.platformContentMaximumHeight, grid.height);
        Flickable {
            anchors.fill: parent;
            contentWidth: parent.width;
            contentHeight: grid.height;
            Grid {
                id: grid;
                width: parent.width;
                columns: 3;
                Repeater {
                    model: ListModel { id: gridModel; }
                    WebHomeDelegate {
                        width: grid.width / 3;
                        iconSource: "../gfx/home_"+file+".png";
                        title: name;
                        onClicked: {
                            root.accept();
                            webView.url = "http://"+url;
                        }
                    }
                }
            }
        }
    }
    buttonTexts: ["关闭"];

    function init(){
        var dict = [["网页","sousuo","m.baidu.com"],
                    ["地图","ditu","map.baidu.com"],
                    ["贴吧","tieba","tieba.baidu.com"],
                    ["视频","shipin","m.video.baidu.com"],
                    ["图片","bizhi","m.baidu.com/img"],
                    ["新闻","xinwen","m.baidu.com/news"],
                    ["音乐","yinyue","music.baidu.com"],
                    ["文库","wenku","wk.baidu.com"],
                    ["百科","baike2","wapbaike.baidu.com"],
                    ["旅游","lvyou2","lvyou.baidu.com"],
                    ["网盘","wangpan","pan.baidu.com"],
                    ["翻译","fanyi","fanyi.baidu.com"]]
        dict.forEach(function(value){
                         gridModel.append({name:value[0],file:value[1],url:value[2]});
                     });
    }

    Component.onCompleted: init();
}
