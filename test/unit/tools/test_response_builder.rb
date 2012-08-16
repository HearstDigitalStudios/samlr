require File.expand_path("test/test_helper")

describe Samlr::Tools::ResponseBuilder do
  before { @certificate = TEST_CERTIFICATE }

  describe "#fixture" do
    subject { saml_response_document(:certificate => @certificate) }

    it "generates a fully valid response document" do
      response = Samlr::Response.new(subject, :certificate => @certificate.x509)
      assert response.verify!
    end

    it "validates against schemas" do
      result = Samlr::Tools.validate(:document => subject)
      assert result
    end
  end
end
