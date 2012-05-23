require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ActsAsAliased" do

  let(:company1) { Company.create(name: "Foo LLC") }
  let(:company2) { Company.create(name: "Foo") }
  let(:department1) { Department.create(title: "Technical Staff") }
  let(:department2) { Department.create(title: "Techies") }
  let(:project1) { Project.create(name: "Project 1", company: company1, department: department1) }
  let(:project2) { Project.create(name: "Project 2", company: company2, department: department2) }
  let(:project3) { Project.create(name: "Project 3", company: company2, department: department2) }


  context "creating an alias" do
    before { clean_database }

    it "should work" do
      expect {
        al = ActsAsAliased::Alias.create(name: "Foo", aliased: company1)
        al.aliased_id.should    == company1.id
        al.aliased_type.should  == 'Company'
        al.name.should          == "Foo"
      }.to change{ ActsAsAliased::Alias.count }.by(1)
    end
  end

  context "converting to alias" do
    before { clean_database }

    it "should create a new alias" do
      expect {
        al = company2.to_alias!(company1)
        al.should be_an(ActsAsAliased::Alias)
        al.aliased.should == company1
        al.name.should    == "Foo"
      }.to change{ ActsAsAliased::Alias.count }.by(1)
    end

    it "should destroy the resource" do
      company1
      company2
      expect {
        company2.to_alias!(company1)
      }.to change{ Company.count }.by(-1)
    end

    it "should raise an exception on self" do
      lambda { company1.to_alias!(company1) }.should raise_error
    end

    context "with associations" do
      before(:each) do
        clean_database
        project1
        project2
        project3
      end

      it "should reassign associations" do
        company2.to_alias!(company1)
        company1.reload.should have(3).projects
      end
    end

    context "with a different column name" do
      before(:each) do
        clean_database
        department2.to_alias!(department1)
      end

      it "should work" do
        Department.lookup("Techies").should == department1
      end
    end
  end

  context "lookup" do
    before(:each) do
      clean_database
      company2.to_alias!(company1)
    end

    it "should find by aliased name" do
      Company.lookup("Foo LLC").should == company1
    end

    it "should find by alias name" do
      Company.lookup("Foo").should == company1
    end

    it "should return nil if not found" do
      Company.lookup("Bar").should be_nil
    end
  end
end
