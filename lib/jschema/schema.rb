module JSchema
  class Schema
    class << self
      def build(sch = {}, parent = nil, id = nil)
        schema = sch || {}

        if (json_reference = schema['$ref'])
          ref_uri = URI(json_reference)
          SchemaRef.new(ref_uri, parent)
        else
          uri = establish_uri(schema, parent, id)
          jschema = new(schema, uri, parent)
          register_definitions schema, jschema
          JSONReference.register_schema jschema
        end
      end

      private

      # rubocop:disable MethodLength
      def establish_uri(schema, parent, id)
        this_id = URI(schema['id'] || id || '#')

        # RFC 3986, cl. 5.1
        if parent
          if parent.uri.absolute?
            parent.uri.merge(this_id).normalize
          elsif parent.uri.path.empty?
            URI('#' + File.join(parent.uri.fragment, id || '')) # FIXME
          else
            # RFC 3986, cl. 5.1.4
            fail InvalidSchema, 'Can not establish a base URI'
          end
        else
          this_id
        end
      end

      def register_definitions(schema, parent)
        if (definitions = schema['definitions'])
          definitions.each do |definition, sch|
            schema_def = build(sch, parent, "definitions/#{definition}")
            JSONReference.register_schema schema_def
          end
        end
      end
    end

    attr_reader :uri, :parent, :errors

    def valid?(instance)
      @validators.all? do |validator|
        validator.valid?(instance).tap do |valid|
          @errors.concat validator.errors unless valid
        end
      end
    end

    private

    def initialize(schema, uri, parent)
      @errors = []
      @uri = uri
      @parent = parent
      @validators = Validator.build(schema, self)
    end
  end
end
