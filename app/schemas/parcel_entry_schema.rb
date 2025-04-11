class ParcelEntrySchema
  def self.schema
    {
      type: "object",
      properties: {
        parcel: {
          type: "object",
          properties: {
            street1: {
              type: "string",
              maxLength: 100,
              description: "Primary street address"
            },
            street2: {
              type: "string",
              maxLength: 100,
              description: "Secondary address line (apartment, suite, etc.)"
            },
            city: {
              type: "string",
              maxLength: 50,
              description: "City name"
            },
            state: {
              type: "string",
              pattern: "^[A-Z]{2}$",
              description: "Two-letter state code"
            },
            zip_code: {
              type: "string",
              pattern: "^\\d{5}(-\\d{4})?$",
              description: "ZIP code in format 12345 or 12345-1234"
            }
          },
          required: [ "street1", "city", "state", "zip_code" ]
        },
        structures: {
          type: "array",
          items: {
            type: "object",
            properties: {
              building_type: {
                type: "string",
                enum: [ "residential", "garage", "shed", "workshop", "barn", "other" ],
                description: "Type of building"
              },
              nickname: {
                type: "string",
                description: "Optional nickname for the structure"
              },
              length: {
                type: "integer",
                minimum: 1,
                description: "Length in feet"
              },
              width: {
                type: "integer",
                minimum: 1,
                description: "Width in feet"
              }
            },
            required: [ "building_type", "length", "width" ]
          }
        }
      },
      required: [ "parcel", "structures" ]
    }
  end
end
