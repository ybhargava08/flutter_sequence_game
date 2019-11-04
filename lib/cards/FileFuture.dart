import 'package:flutter/material.dart';
import 'package:sequence/firebasestorage/FirebaseStorageUtil.dart';

class FileFuture extends StatelessWidget {

  final String filename;

  final String type;

  final Color color;

  final BlendMode blendMode;

  FileFuture(this.filename,this.type,this.color,this.blendMode); 

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: FirebaseStorageUtil().getFileDownloadUrl(filename, type),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
             if(snapshot.hasData && null!=snapshot.data) {
                  if(null!=color && null!=blendMode) {
                      return Image.network(snapshot.data,fit: BoxFit.contain,color: color,colorBlendMode: blendMode,);
                  }else{
                      return Image.network(snapshot.data,fit: BoxFit.contain,);
                  }              
             }
             return Container(width: 0,height: 0,);
        },
    );
  }

}