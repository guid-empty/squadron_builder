import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:squadron/squadron_annotations.dart';

import 'annotations_reader.dart';
import 'marshaling_manager.dart';
import 'squadron_parameters.dart';

/// Reader for a Squadron service class
class SquadronServiceReader {
  SquadronServiceReader._(ClassElement clazz, this.pool, this.vm, this.web,
      this.baseUrl, this.logger)
      : name = clazz.name {
    _load(clazz);
  }

  final fields = <String, FieldElement>{};
  final accessors = <PropertyAccessorElement>[];
  final methods = <MethodElement>[];

  final String name;
  final bool pool;
  final bool vm;
  final bool web;
  final String baseUrl;
  final String? logger;

  final parameters = SquadronParameters();

  final _marshaling = MarshalingManager();

  void _load(ClassElement clazz) {
    if (clazz.isAbstract ||
        clazz.isInterface ||
        clazz.isSealed ||
        clazz.isFinal ||
        clazz.isBase ||
        !clazz.isConstructable ||
        clazz.name.startsWith('_')) {
      throw InvalidGenerationSourceError(
          'A service class must be public and concrete.');
    }

    final ctorElement = clazz.unnamedConstructor;

    if (ctorElement == null) {
      if (clazz.constructors.isNotEmpty) {
        log.warning('No unnamed constructor found for ${clazz.name}');
      }
    } else if (ctorElement.parameters.isNotEmpty) {
      for (var n = 0; n < ctorElement.parameters.length; n++) {
        final param = ctorElement.parameters[n];

        if (param is FieldFormalParameterElement && param.field != null) {
          if (!param.field!.name.startsWith('_')) {
            fields[param.name] = param.field!;
          }
        }

        final marshaler = _marshaling.getMarshalerFor(param);
        final p = parameters.register(param, marshaler);
        if (p.isCancellationToken) {
          throw InvalidGenerationSourceError(
              'Cancellation tokens are not supported during service initialization.');
        }
      }
    }

    methods.addAll(clazz.methods.where((m) => !m.isStatic));
    accessors.addAll(clazz.accessors.where((a) =>
        !a.isStatic &&
        ((a.isGetter && !fields.containsKey(a.name)) ||
            (a.isSetter && !fields.containsKey(a.name.replaceAll('=', ''))))));
  }

  static SquadronServiceReader? load(ClassElement clazz) {
    final reader = AnnotationReader<SquadronService>(clazz);
    if (reader.isEmpty) return null;
    final pool = reader.isSet('pool');
    final vm = reader.isSet('vm');
    final web = reader.isSet('web');
    var baseUrl = reader.getString('baseUrl') ?? '';
    if (baseUrl.isNotEmpty && baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    final logger = AnnotationReader.getLogger(clazz);
    return SquadronServiceReader._(clazz, pool, vm, web, baseUrl, logger);
  }
}
