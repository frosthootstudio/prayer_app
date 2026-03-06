import 'package:hive/hive.dart';

/// Tracks completion state of a single ibadah task for a specific date.
class IbadahTracking {
  final String  date;      // 'yyyy-MM-dd'
  final String  taskKey;   // e.g. 'tahajud'
  bool          isDone;
  DateTime?     timestamp; // when it was checked off

  IbadahTracking({
    required this.date,
    required this.taskKey,
    this.isDone    = false,
    this.timestamp,
  });
}

/// Manual TypeAdapter — no build_runner needed.
class IbadahTrackingAdapter extends TypeAdapter<IbadahTracking> {
  @override
  final int typeId = 2;

  @override
  IbadahTracking read(BinaryReader reader) {
    final date    = reader.readString();
    final taskKey = reader.readString();
    final isDone  = reader.readBool();
    final hasTs   = reader.readBool();
    final ts      = hasTs
        ? DateTime.fromMillisecondsSinceEpoch(reader.readInt())
        : null;
    return IbadahTracking(
      date: date, taskKey: taskKey, isDone: isDone, timestamp: ts,
    );
  }

  @override
  void write(BinaryWriter writer, IbadahTracking obj) {
    writer.writeString(obj.date);
    writer.writeString(obj.taskKey);
    writer.writeBool(obj.isDone);
    final ts = obj.timestamp;
    if (ts != null) {
      writer.writeBool(true);
      writer.writeInt(ts.millisecondsSinceEpoch);
    } else {
      writer.writeBool(false);
    }
  }
}
