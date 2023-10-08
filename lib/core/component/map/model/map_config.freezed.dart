// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

MapConfig _$MapConfigFromJson(Map<String, dynamic> json) {
  return _MapConfig.fromJson(json);
}

/// @nodoc
mixin _$MapConfig {
  double get minScale => throw _privateConstructorUsedError;
  double get maxScale => throw _privateConstructorUsedError;
  MapColorScheme get colorScheme => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MapConfigCopyWith<MapConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MapConfigCopyWith<$Res> {
  factory $MapConfigCopyWith(MapConfig value, $Res Function(MapConfig) then) =
      _$MapConfigCopyWithImpl<$Res, MapConfig>;
  @useResult
  $Res call({double minScale, double maxScale, MapColorScheme colorScheme});

  $MapColorSchemeCopyWith<$Res> get colorScheme;
}

/// @nodoc
class _$MapConfigCopyWithImpl<$Res, $Val extends MapConfig>
    implements $MapConfigCopyWith<$Res> {
  _$MapConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minScale = null,
    Object? maxScale = null,
    Object? colorScheme = null,
  }) {
    return _then(_value.copyWith(
      minScale: null == minScale
          ? _value.minScale
          : minScale // ignore: cast_nullable_to_non_nullable
              as double,
      maxScale: null == maxScale
          ? _value.maxScale
          : maxScale // ignore: cast_nullable_to_non_nullable
              as double,
      colorScheme: null == colorScheme
          ? _value.colorScheme
          : colorScheme // ignore: cast_nullable_to_non_nullable
              as MapColorScheme,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MapColorSchemeCopyWith<$Res> get colorScheme {
    return $MapColorSchemeCopyWith<$Res>(_value.colorScheme, (value) {
      return _then(_value.copyWith(colorScheme: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_MapConfigCopyWith<$Res> implements $MapConfigCopyWith<$Res> {
  factory _$$_MapConfigCopyWith(
          _$_MapConfig value, $Res Function(_$_MapConfig) then) =
      __$$_MapConfigCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double minScale, double maxScale, MapColorScheme colorScheme});

  @override
  $MapColorSchemeCopyWith<$Res> get colorScheme;
}

/// @nodoc
class __$$_MapConfigCopyWithImpl<$Res>
    extends _$MapConfigCopyWithImpl<$Res, _$_MapConfig>
    implements _$$_MapConfigCopyWith<$Res> {
  __$$_MapConfigCopyWithImpl(
      _$_MapConfig _value, $Res Function(_$_MapConfig) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minScale = null,
    Object? maxScale = null,
    Object? colorScheme = null,
  }) {
    return _then(_$_MapConfig(
      minScale: null == minScale
          ? _value.minScale
          : minScale // ignore: cast_nullable_to_non_nullable
              as double,
      maxScale: null == maxScale
          ? _value.maxScale
          : maxScale // ignore: cast_nullable_to_non_nullable
              as double,
      colorScheme: null == colorScheme
          ? _value.colorScheme
          : colorScheme // ignore: cast_nullable_to_non_nullable
              as MapColorScheme,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_MapConfig implements _MapConfig {
  const _$_MapConfig(
      {this.minScale = 0.8, this.maxScale = 20, required this.colorScheme});

  factory _$_MapConfig.fromJson(Map<String, dynamic> json) =>
      _$$_MapConfigFromJson(json);

  @override
  @JsonKey()
  final double minScale;
  @override
  @JsonKey()
  final double maxScale;
  @override
  final MapColorScheme colorScheme;

  @override
  String toString() {
    return 'MapConfig(minScale: $minScale, maxScale: $maxScale, colorScheme: $colorScheme)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_MapConfig &&
            (identical(other.minScale, minScale) ||
                other.minScale == minScale) &&
            (identical(other.maxScale, maxScale) ||
                other.maxScale == maxScale) &&
            (identical(other.colorScheme, colorScheme) ||
                other.colorScheme == colorScheme));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, minScale, maxScale, colorScheme);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MapConfigCopyWith<_$_MapConfig> get copyWith =>
      __$$_MapConfigCopyWithImpl<_$_MapConfig>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MapConfigToJson(
      this,
    );
  }
}

abstract class _MapConfig implements MapConfig {
  const factory _MapConfig(
      {final double minScale,
      final double maxScale,
      required final MapColorScheme colorScheme}) = _$_MapConfig;

  factory _MapConfig.fromJson(Map<String, dynamic> json) =
      _$_MapConfig.fromJson;

  @override
  double get minScale;
  @override
  double get maxScale;
  @override
  MapColorScheme get colorScheme;
  @override
  @JsonKey(ignore: true)
  _$$_MapConfigCopyWith<_$_MapConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

MapColorScheme _$MapColorSchemeFromJson(Map<String, dynamic> json) {
  return _MapColorScheme.fromJson(json);
}

/// @nodoc
mixin _$MapColorScheme {
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  Color get backgroundColor => throw _privateConstructorUsedError;
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  Color get worldLandColor => throw _privateConstructorUsedError;
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  Color get worldCoastlineColor => throw _privateConstructorUsedError;
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  Color get worldBorderLineColor => throw _privateConstructorUsedError;
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  Color get japanLandColor => throw _privateConstructorUsedError;
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  Color get japanCoastlineColor => throw _privateConstructorUsedError;
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  Color get japanBorderLineColor => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MapColorSchemeCopyWith<MapColorScheme> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MapColorSchemeCopyWith<$Res> {
  factory $MapColorSchemeCopyWith(
          MapColorScheme value, $Res Function(MapColorScheme) then) =
      _$MapColorSchemeCopyWithImpl<$Res, MapColorScheme>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          Color backgroundColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          Color worldLandColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          Color worldCoastlineColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          Color worldBorderLineColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          Color japanLandColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          Color japanCoastlineColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          Color japanBorderLineColor});
}

/// @nodoc
class _$MapColorSchemeCopyWithImpl<$Res, $Val extends MapColorScheme>
    implements $MapColorSchemeCopyWith<$Res> {
  _$MapColorSchemeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? backgroundColor = null,
    Object? worldLandColor = null,
    Object? worldCoastlineColor = null,
    Object? worldBorderLineColor = null,
    Object? japanLandColor = null,
    Object? japanCoastlineColor = null,
    Object? japanBorderLineColor = null,
  }) {
    return _then(_value.copyWith(
      backgroundColor: null == backgroundColor
          ? _value.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as Color,
      worldLandColor: null == worldLandColor
          ? _value.worldLandColor
          : worldLandColor // ignore: cast_nullable_to_non_nullable
              as Color,
      worldCoastlineColor: null == worldCoastlineColor
          ? _value.worldCoastlineColor
          : worldCoastlineColor // ignore: cast_nullable_to_non_nullable
              as Color,
      worldBorderLineColor: null == worldBorderLineColor
          ? _value.worldBorderLineColor
          : worldBorderLineColor // ignore: cast_nullable_to_non_nullable
              as Color,
      japanLandColor: null == japanLandColor
          ? _value.japanLandColor
          : japanLandColor // ignore: cast_nullable_to_non_nullable
              as Color,
      japanCoastlineColor: null == japanCoastlineColor
          ? _value.japanCoastlineColor
          : japanCoastlineColor // ignore: cast_nullable_to_non_nullable
              as Color,
      japanBorderLineColor: null == japanBorderLineColor
          ? _value.japanBorderLineColor
          : japanBorderLineColor // ignore: cast_nullable_to_non_nullable
              as Color,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_MapColorSchemeCopyWith<$Res>
    implements $MapColorSchemeCopyWith<$Res> {
  factory _$$_MapColorSchemeCopyWith(
          _$_MapColorScheme value, $Res Function(_$_MapColorScheme) then) =
      __$$_MapColorSchemeCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          Color backgroundColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          Color worldLandColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          Color worldCoastlineColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          Color worldBorderLineColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          Color japanLandColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          Color japanCoastlineColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          Color japanBorderLineColor});
}

/// @nodoc
class __$$_MapColorSchemeCopyWithImpl<$Res>
    extends _$MapColorSchemeCopyWithImpl<$Res, _$_MapColorScheme>
    implements _$$_MapColorSchemeCopyWith<$Res> {
  __$$_MapColorSchemeCopyWithImpl(
      _$_MapColorScheme _value, $Res Function(_$_MapColorScheme) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? backgroundColor = null,
    Object? worldLandColor = null,
    Object? worldCoastlineColor = null,
    Object? worldBorderLineColor = null,
    Object? japanLandColor = null,
    Object? japanCoastlineColor = null,
    Object? japanBorderLineColor = null,
  }) {
    return _then(_$_MapColorScheme(
      backgroundColor: null == backgroundColor
          ? _value.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as Color,
      worldLandColor: null == worldLandColor
          ? _value.worldLandColor
          : worldLandColor // ignore: cast_nullable_to_non_nullable
              as Color,
      worldCoastlineColor: null == worldCoastlineColor
          ? _value.worldCoastlineColor
          : worldCoastlineColor // ignore: cast_nullable_to_non_nullable
              as Color,
      worldBorderLineColor: null == worldBorderLineColor
          ? _value.worldBorderLineColor
          : worldBorderLineColor // ignore: cast_nullable_to_non_nullable
              as Color,
      japanLandColor: null == japanLandColor
          ? _value.japanLandColor
          : japanLandColor // ignore: cast_nullable_to_non_nullable
              as Color,
      japanCoastlineColor: null == japanCoastlineColor
          ? _value.japanCoastlineColor
          : japanCoastlineColor // ignore: cast_nullable_to_non_nullable
              as Color,
      japanBorderLineColor: null == japanBorderLineColor
          ? _value.japanBorderLineColor
          : japanBorderLineColor // ignore: cast_nullable_to_non_nullable
              as Color,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_MapColorScheme implements _MapColorScheme {
  const _$_MapColorScheme(
      {@JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          required this.backgroundColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          required this.worldLandColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          required this.worldCoastlineColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          required this.worldBorderLineColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          required this.japanLandColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          required this.japanCoastlineColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          required this.japanBorderLineColor});

  factory _$_MapColorScheme.fromJson(Map<String, dynamic> json) =>
      _$$_MapColorSchemeFromJson(json);

  @override
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  final Color backgroundColor;
  @override
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  final Color worldLandColor;
  @override
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  final Color worldCoastlineColor;
  @override
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  final Color worldBorderLineColor;
  @override
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  final Color japanLandColor;
  @override
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  final Color japanCoastlineColor;
  @override
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  final Color japanBorderLineColor;

  @override
  String toString() {
    return 'MapColorScheme(backgroundColor: $backgroundColor, worldLandColor: $worldLandColor, worldCoastlineColor: $worldCoastlineColor, worldBorderLineColor: $worldBorderLineColor, japanLandColor: $japanLandColor, japanCoastlineColor: $japanCoastlineColor, japanBorderLineColor: $japanBorderLineColor)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_MapColorScheme &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.worldLandColor, worldLandColor) ||
                other.worldLandColor == worldLandColor) &&
            (identical(other.worldCoastlineColor, worldCoastlineColor) ||
                other.worldCoastlineColor == worldCoastlineColor) &&
            (identical(other.worldBorderLineColor, worldBorderLineColor) ||
                other.worldBorderLineColor == worldBorderLineColor) &&
            (identical(other.japanLandColor, japanLandColor) ||
                other.japanLandColor == japanLandColor) &&
            (identical(other.japanCoastlineColor, japanCoastlineColor) ||
                other.japanCoastlineColor == japanCoastlineColor) &&
            (identical(other.japanBorderLineColor, japanBorderLineColor) ||
                other.japanBorderLineColor == japanBorderLineColor));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      backgroundColor,
      worldLandColor,
      worldCoastlineColor,
      worldBorderLineColor,
      japanLandColor,
      japanCoastlineColor,
      japanBorderLineColor);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MapColorSchemeCopyWith<_$_MapColorScheme> get copyWith =>
      __$$_MapColorSchemeCopyWithImpl<_$_MapColorScheme>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MapColorSchemeToJson(
      this,
    );
  }
}

abstract class _MapColorScheme implements MapColorScheme {
  const factory _MapColorScheme(
      {@JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          required final Color backgroundColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          required final Color worldLandColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          required final Color worldCoastlineColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          required final Color worldBorderLineColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          required final Color japanLandColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          required final Color japanCoastlineColor,
      @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
          required final Color japanBorderLineColor}) = _$_MapColorScheme;

  factory _MapColorScheme.fromJson(Map<String, dynamic> json) =
      _$_MapColorScheme.fromJson;

  @override
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  Color get backgroundColor;
  @override
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  Color get worldLandColor;
  @override
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  Color get worldCoastlineColor;
  @override
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  Color get worldBorderLineColor;
  @override
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  Color get japanLandColor;
  @override
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  Color get japanCoastlineColor;
  @override
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  Color get japanBorderLineColor;
  @override
  @JsonKey(ignore: true)
  _$$_MapColorSchemeCopyWith<_$_MapColorScheme> get copyWith =>
      throw _privateConstructorUsedError;
}