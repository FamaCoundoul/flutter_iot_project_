class LEDStatusResponse {
  String? status;
  bool? state;
  int? timestamp;

  LEDStatusResponse({this.status, this.state, this.timestamp});

  LEDStatusResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    state = json['state'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['state'] = this.state;
    data['timestamp'] = this.timestamp;
    return data;
  }
}
