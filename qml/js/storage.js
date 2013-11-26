.pragma library

var QUERY = {
    DBVER: "2.0",
    CREATE_AuthData_TABLE: 'CREATE TABLE IF NOT EXISTS AuthData(id TEXT UNIQUE, name TEXT, BDUSS TEXT, passwd TEXT, portrait TEXT)',
    CREATE_LikeForum_TABLE: 'CREATE TABLE IF NOT EXISTS LikeForum(forum_id TEXT UNIQUE, forum_name TEXT, level_id INTEGER)'
};

var db;
if (typeof(db) === "undefined"){
    db = openDatabaseSync("tbclient", "", "Tieba Database", 1000000);
}

if (db.version !== QUERY.DBVER){
    db.changeVersion(db.version, QUERY.DBVER, function(tx){
                         try { tx.executeSql('DROP TABLE AuthData') }catch(e){};
                         try { tx.executeSql('DROP TABLE LikeForum') }catch(e){};
                         tx.executeSql(QUERY.CREATE_AuthData_TABLE);
                         tx.executeSql(QUERY.CREATE_LikeForum_TABLE);
                     })
} else {
    db.transaction(function(tx){
                       tx.executeSql(QUERY.CREATE_AuthData_TABLE);
                       tx.executeSql(QUERY.CREATE_LikeForum_TABLE);
                   })
}

function storeAuthData(id, name, BDUSS, passwd, portrait){
    db.transaction(function(tx){
                       tx.executeSql('INSERT OR REPLACE INTO AuthData VALUES (?,?,?,?,?)',
                                     [id, name, BDUSS, passwd, portrait]);
                   })
}

function loadAuthData(id){
    var result = [];
    db.readTransaction(function(tx){
                           if (id !== undefined){
                               var rs = tx.executeSql('SELECT * FROM AuthData WHERE id=?;',[id]);
                               if (rs.rows.length > 0){
                                   result.push(rs.rows.item(0));
                               }
                           } else {
                               var rs = tx.executeSql('SELECT * FROM AuthData');
                               for (var i=0, l=rs.rows.length; i<l; i++){
                                   result.push(rs.rows.item(i));
                               }
                           }
                       })
    return result;
}

function deleteAuthData(id){
    db.transaction(function(tx){
                       if (id !== undefined){
                           tx.executeSql('DELETE FROM AuthData WHERE id=?;',[id]);
                       } else {
                           tx.executeSql('DELETE FROM AuthData');
                       }
                   });
}

function loadLikeForum(model){
    model.clear();
    db.readTransaction(function(tx){
                           var rs = tx.executeSql('SELECT * FROM LikeForum');
                           for (var i=0, l=rs.rows.length; i<l; i++){
                               var value = rs.rows.item(i);
                               var prop = {
                                   forum_id: value.forum_id,
                                   is_sign: false,
                                   forum_name: value.forum_name,
                                   level_id: Number(value.level_id)
                               };
                               model.append(prop);
                           }
                       })
    return model.count > 0;
}
